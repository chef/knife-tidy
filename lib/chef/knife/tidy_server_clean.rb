require 'chef/knife/tidy_base'

class Chef
  class Knife
    class TidyServerClean < Knife
      include Knife::TidyBase

      deps do
        require 'ffi_yajl'
        require 'chef/util/threaded_job_queue'
      end

      banner 'knife tidy server clean (options)'

      option :backup_path,
        long: '--backup-path path/to/backup',
        description: 'The path to the knife-ec-backup backup directory'

      option :concurrency,
        long: '--concurrency THREADS',
        default: 1,
        description: 'Maximum number of simultaneous requests to send (default: 1)'

      option :only_cookbooks,
        long: '--only-cookbooks',
        description: 'Only delete unused cookbooks from Chef Server.'

      option :only_nodes,
        long: '--only-nodes',
        description: 'Only delete stale nodes (and associated clients and ACLs) from Chef Server.'

      option :dry_run,
        long: '--dry-run',
        description: 'Do not perform any actual deletion, only report on what would have been deleted.'

      def run
        STDOUT.sync = true

        ensure_reports_dir

        configure_chef

        if config[:only_cookbooks] && config[:only_nodes]
          ui.error 'Cannot use --only-cookbooks AND --only-nodes'
          exit 1
        end

        while config[:backup_path].nil?
          user_value = ui.ask_question("It is not recommended to run this command without specifying a current backup directory.\nPlease specify a backup directory:")
          config[:backup_path] = user_value == '' ? nil : user_value
        end

        unless ::File.directory?(config[:backup_path])
          ui.error 'Must specify valid --backup-path'
          exit 1
        end

        deletions = if config[:only_cookbooks]
                      'cookbooks'
                    elsif config[:only_nodes]
                      'nodes (and associated clients and ACLs)'
                    else
                      'cookbooks and nodes (and associated clients and ACLs)'
                    end

        orgs = if config[:org_list]
                 config[:org_list].split(',')
               else
                 all_orgs
               end

        ui.warn "This operation will affect the following Orgs on #{server.root_url}: #{orgs}"
        if ::File.exist?(server_warnings_file_path)
          ::File.read(::File.expand_path('reports/knife-tidy-server-warnings.txt')).each_line do |line|
            ui.warn(line)
          end
        end
        ui.confirm("This command will delete #{deletions} identified by the knife-tidy reports in #{tidy.reports_dir} from the Chef Server specified in your knife configuration file. \n\n The Chef server to be used is currently #{server.root_url}.\n\n Please be sure this is the Chef server you wish to delete data from. \n\nWould you like to continue?") unless config[:unattended]

        orgs.each do |org|
          clean_cookbooks(org) unless config[:only_nodes]
          clean_nodes(org) unless config[:only_cookbooks]
        end

        completion_message
      end

      def clean_cookbooks(org)
        queue = Chef::Util::ThreadedJobQueue.new
        unused_cookbooks_file = ::File.join(tidy.reports_dir, "#{org}_unused_cookbooks.json")
        return unless ::File.exist?(unused_cookbooks_file)
        ui.stdout.puts "INFO: Cleaning cookbooks for Org: #{org}, using #{unused_cookbooks_file}"
        unused_cookbooks = FFI_Yajl::Parser.parse(::File.read(unused_cookbooks_file), symbolize_names: true)
        unused_cookbooks.keys.each do |cookbook|
          versions = unused_cookbooks[cookbook]
          versions.each do |version|
            queue << -> { delete_cookbook_job(org, cookbook, version) }
          end
        end
        queue.process(config[:concurrency].to_i)
      end

      def delete_cookbook_job(org, cookbook, version)
        path = "/organizations/#{org}/cookbooks/#{cookbook}/#{version}"
        if config[:dry_run]
          printf("DRYRUN: Would have executed `rest.delete(#{path})`\n")
          return
        end
        printf("INFO: Deleting #{path}\n")
        rest.delete(path)
      rescue Net::HTTPServerException
      end

      def clean_nodes(org)
        queue = Chef::Util::ThreadedJobQueue.new
        stale_nodes_file = ::File.join(tidy.reports_dir, "#{org}_stale_nodes.json")
        return unless ::File.exist?(stale_nodes_file)
        ui.stdout.puts "INFO: Cleaning stale nodes for Org: #{org}, using #{stale_nodes_file}"
        stale_nodes = FFI_Yajl::Parser.parse(::File.read(stale_nodes_file), symbolize_names: true)
        stale_nodes[:list].each do |node|
          queue << -> { delete_node_job(org, node) }
        end
        queue.process(config[:concurrency].to_i)
      end

      def delete_node_job(org, node)
        paths = ["/organizations/#{org}/nodes/#{node}", "/organizations/#{org}/clients/#{node}"]
        paths.each do |path|
          if config[:dry_run]
            printf("DRYRUN: Would have executed `rest.delete(#{path})`\n")
            next
          else
            begin
              printf("INFO: Deleting #{path}\n")
              rest.delete(path)
            rescue Net::HTTPServerException
            end
          end
        end
      end

      def ensure_reports_dir
        unless ::File.directory?(tidy.reports_dir)
          ui.error "#{tidy.reports_dir} not found!"
          exit 1
        end
      end

      def report_files
        Dir[::File.join(tidy.reports_dir, '**.json')]
      end

      def all_orgs
        orgs = []
        report_files.each do |file|
          org = ::File.basename(file).match(/^(.*?)_(cookbook_count|unused_cookbooks|stale_nodes)\.json/).captures[0]
          if org
            orgs.push(org) unless orgs.include?(org)
          end
        end
        orgs
      end
    end
  end
end
