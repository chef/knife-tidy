require 'chef/knife/tidy_base'

class Chef
  class Knife
    class TidyServerClean < Knife

      include Knife::TidyBase

      deps do
        require 'ffi_yajl'
        require 'chef/util/threaded_job_queue'
      end

      banner "knife tidy server clean (options)"

      option :concurrency,
        :long => '--concurrency THREADS',
        :default => 10,
        :description => 'Maximum number of simultaneous requests to send (default: 10)'

      option :only_cookbooks,
        :long => '--only-cookbooks',
        :description => 'Only delete unused cookbooks from Chef Server.'

      option :only_nodes,
        :long => '--only-nodes',
        :description => 'Only delete stale nodes from Chef Server.'

      def run
        STDOUT.sync = true

        ensure_reports_dir
        ui.info "Reading from #{tidy.reports_dir} directory"

        ui.info "Using thread concurrency #{config[:concurrency]}"
        configure_chef

        if config[:only_cookbooks] && config[:only_nodes]
          ui.error 'Cannot use --only-cookbooks AND --only-nodes'
          exit 1
        end

        ui.confirm('This operation will delete items on Chef Server, continue') unless config[:unattended]

        orgs = if config[:org_list]
                 config[:org_list].split(',')
               else
                 all_orgs
               end

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
        ui.info "Cleaning cookbooks for Org: #{org}, using #{unused_cookbooks_file}"
        unused_cookbooks = FFI_Yajl::Parser.parse(::File.read(unused_cookbooks_file), symbolize_names: true)
        unused_cookbooks.keys.each do |cookbook|
          versions = unused_cookbooks[cookbook]
          versions.each do |version|
            queue << lambda { delete_cookbook_job(org, cookbook, version) }
          end
        end
        queue.process(config[:concurrency].to_i)
      end

      def delete_cookbook_job(org, cookbook, version)
        path = "/organizations/#{org}/cookbooks/#{cookbook}/#{version}"
        rest.delete(path)
        response = '200'
      rescue Net::HTTPServerException
        response = $!.response.code
      ensure
        formatted = response == '200' ?
          ui.color(' Deleting  %-20s %-10s %10s', :green) :
          ui.color(' Deleting  %-20s %-10s %10s', :red)
        printf("#{formatted}\n", cookbook, version, response)
      end

      def clean_nodes(org)
        queue = Chef::Util::ThreadedJobQueue.new
        stale_nodes_file = ::File.join(tidy.reports_dir, "#{org}_stale_nodes.json")
        return unless ::File.exist?(stale_nodes_file)
        ui.info "Cleaning stale nodes for Org: #{org}, using #{stale_nodes_file}"
        stale_nodes = FFI_Yajl::Parser.parse(::File.read(stale_nodes_file), symbolize_names: true)
        stale_nodes[:list].each do |node|
          queue << lambda { delete_node_job(org, node) }
        end
        queue.process(config[:concurrency].to_i)
      end

      def delete_node_job(org, node)
        path = "/organizations/#{org}/nodes/#{node}"
        rest.delete(path)
        response = '200'
      rescue Net::HTTPServerException
        response = $!.response.code
      ensure
        formatted = response == '200' ?
          ui.color(' Deleting  %-20s %10s', :green) :
          ui.color(' Deleting  %-20s %10s', :red)
        printf("#{formatted}\n", node, response)
      end

      def ensure_reports_dir
        unless ::File.directory?(tidy.reports_dir)
          ui.error "#{tidy.reports_dir} not found!"
          exit 1
        end
      end

      def report_files
        Dir[::File.join(tidy.reports_dir, '**')]
      end

      def all_orgs
        orgs = []
        report_files.each do |file|
          org = ::File.basename(file).match(/^(.*?)_/).captures[0]
          if org
            orgs.push(org) unless orgs.include?(org)
          end
        end
        orgs
      end
    end
  end
end
