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
          end

          option :org_list,
            :long => "--orgs ORG1,ORG2",
            :description => "Only apply to objects in the named organizations"
          end
      end

      def server
        @server ||= if Chef::Config.chef_server_root.nil?
                      ui.warn("chef_server_root not found in knife configuration; using chef_server_url")
                      Chef::TidyServer.from_chef_server_url(Chef::Config.chef_server_url)
                    else
                      Chef::TidyServer.new(Chef::Config.chef_server_root)
                    end
      end

      def rest
        @rest ||= Chef::ServerAPI.new(server.root_url, {:api_version => "0"})
      end

      def backup_path_expanded
        @backup_path_expanded ||= ::File.expand_path(config[:backup_path])
      end

      def cookbook_name_from_path(path)
        ::File.basename(path, '-*')
      end

      def cookbooks_path_expanded(org)
        ::File.expand_path(::File.join(backup_path_expanded, 'organizations', org, 'cookbooks'))
      end

      def global_users_path_expanded
        @global_users_path_expanded ||= ::File.expand_path(::File.join(backup_path_expanded, 'users'))
      end

      def substitutions_file
        @substitutions_file ||= ::File.expand_path(config[:gsub_file])
      end

      def global_users
        @global_users ||= Dir[::File.join(backup_path_expanded, 'users', '*')].map { |dir| ::File.basename(dir, '.json') }
      end

      def orgs
        @orgs ||= if config[:org_list]
                    config[:org_list].split(',')
                  else
                    Dir[::File.join(backup_path_expanded, 'organizations', '*')].map { |dir| ::File.basename(dir) }
                  end
      end

      def for_each_cookbook_basename(org)
        cookbooks_seen = []
        Dir[::File.join(cookbooks_path_expanded(org), '**-**')].each do |cookbook|
          name = cookbook_name_from_path(cookbook)
          unless cookbooks_seen.include?(name)
            cookbooks_seen.push(name)
            yield name
          end
        end
      end

      def for_each_cookbook_path(org)
        Dir[::File.join(cookbooks_path_expanded(org), '**')].each do |cookbook|
          yield cookbook
        end
      end
    end
  end
end
