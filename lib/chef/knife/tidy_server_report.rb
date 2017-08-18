require 'chef/knife/tidy_base'

class Chef
  class Knife
    class TidyServerReport < Knife

      include Knife::TidyBase

      deps do
        require 'ffi_yajl'
      end

      banner "knife tidy server_report (options)"

      option :node_threshold,
        :long => '--node-threshold NUM_DAYS',
        :default => 30,
        :description => 'Maximum number of days since last checkin before node is considered stale (default: 30)'

      def run
        ensure_reports_dir!

        ui.warn "Writing to #{reports_dir} directory"
        delete_existing_reports

        orgs = if config[:org_list]
                 config[:org_list].split(',')
               else
                 all_orgs
               end

        stale_orgs = []
        node_threshold = config[:node_threshold]

        orgs.each do |org|
          ui.info "  Organization: #{org}"
          cb_list = cookbook_list(org)
          version_count = cookbook_count(cb_list).sort_by(&:last).reverse.to_h
          used_cookbooks = {}
          nodes = nodes_list(org)[0]

          nodes.select{|node| !node['cookbooks'].nil?}.each do |node|
            node['cookbooks'].each do |name, version_hash|
              version = Gem::Version.new(version_hash['version']).to_s
              if used_cookbooks[name] && !used_cookbooks[name].include?(version)
                used_cookbooks[name].push(version)
              else
                used_cookbooks[name] = [version]
              end
            end
          end

          stale_nodes = []
          nodes.each do |n|
            if (Time.now.to_i - n['ohai_time'].to_i) >= node_threshold * 86400
              stale_nodes.push(n['name'])
            end
          end

          stale_nodes_hash = {'threshold_days': node_threshold, 'count': stale_nodes.count, 'list': stale_nodes}
          stale_orgs.push(org) if stale_nodes.count == nodes.count

          report("#{org}_unused_cookbooks.json", unused_cookbooks(used_cookbooks, cb_list))
          report("#{org}_unused_cookbooks.json", unused_cookbooks(used_cookbooks, cb_list))
          report("#{org}_cookbook_count.json", version_count)
          report("#{org}_#{node_threshold}d_stale_nodes.json", stale_nodes_hash)
        end
      end

      def report(file_name, content)
        ::File.write(::File.join(reports_dir, file_name), FFI_Yajl::Encoder.encode(content, pretty: true))
      end

      def reports_dir
        ::File.join(Dir.pwd, 'reports')
      end

      def ensure_reports_dir!
        Dir.mkdir(reports_dir) unless Dir.exist?(reports_dir)
      end

      def delete_existing_reports
        files = Dir[::File.join(reports_dir, '*.json')]
        unless files.empty?
          ui.confirm("You have existing reports in #{reports_dir}. Remove")
          FileUtils.rm(files, :force => true)
        end
      end

      def nodes_list(org)
        Chef::Search::Query.new("#{server.root_url}/organizations/#{org}").search(
          :node, '*:*',
          :filter_result => {
            'name' => ['name'],
            'cookbooks' => ['cookbooks'],
            'ohai_time' => ['ohai_time']
          }
        )
      end

      def cookbook_list(org)
        cb_list = {}
        rest.get("/organizations/#{org}/cookbooks?num_versions=all").each do |name, data|
          data['versions'].each do |version_hash|
            version = Gem::Version.new(version_hash['version']).to_s
            if cb_list[name] && !cb_list[name].include?(version)
              cb_list[name].push(version)
            else
              cb_list[name] = [version]
            end
          end
        end
        cb_list
      end

      def cookbook_count(cb_list)
        cb_count_list = {}
        cb_list.each do |name, versions|
          cb_count_list[name] = versions.count
        end
        cb_count_list
      end

      def unused_cookbooks(used_list, cb_list)
        unused_list = {}
        cb_list.each do |name, versions|
          if used_list[name].nil? # Not in the used list at all (Remove all versions)
            unused_list[name] = versions
          elsif used_list[name].sort != versions  # Is in the used cookbook list, but version arrays do not match (Find unused versions)
            unused_list[name] = versions - used_list[name]
          end
        end
        unused_list
      end

      def all_orgs
        rest.get('organizations').keys
      end
    end
  end
end
