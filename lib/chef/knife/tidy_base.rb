# Author:: Jeremy Miller (<jmiller@chef.io>)
# Copyright:: Copyright (c) 2017 Chef Software, Inc.
# License:: Apache License, Version 2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

require 'chef/knife'
require 'chef/server_api'

class Chef
  class Knife
    module TidyBase
      def self.included(includer)
        includer.class_eval do
          deps do
            require 'chef/tidy_server'
            require 'chef/tidy_common'
          end

          option :org_list,
            long: '--orgs ORG1,ORG2',
            description: 'Only apply to objects in the named organizations'
        end
      end

      def server
        @server ||= if Chef::Config.chef_server_root.nil?
                      ui.warn('chef_server_root not found in knife configuration; using chef_server_url')
                      Chef::TidyServer.from_chef_server_url(Chef::Config.chef_server_url)
                    else
                      Chef::TidyServer.new(Chef::Config.chef_server_root)
                    end
      end

      def rest
        @rest ||= Chef::ServerAPI.new(server.root_url, keepalives: true)
      end

      def tidy
        @tidy ||= if config[:backup_path].nil?
                    Chef::TidyCommon.new
                  else
                    Chef::TidyCommon.new(config[:backup_path])
                  end
      end

      def completion_message
        ui.stdout.puts ui.color('** Finished **', :magenta).to_s
      end

      def action_needed_file_path
        ::File.expand_path('knife-tidy-actions-needed.txt')
      end

      def server_warnings_file_path
        ::File.expand_path('reports/knife-tidy-server-warnings.txt')
      end

      def action_needed(msg, file_path = action_needed_file_path)
        ::File.open(file_path, 'a') do |f|
          f.write(msg + "\n")
        end
      end
    end
  end
end
