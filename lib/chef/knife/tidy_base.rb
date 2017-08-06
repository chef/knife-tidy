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

class Chef
  class Knife
    module TidyBase
      def self.included(includer)
        includer.class_eval do

          deps do
            require 'readline'
            require 'chef/json_compat'
          end

          option :org,
            :long => "--only-org ORG",
            :description => "Only apply to objects in the named organization (default: all orgs)"
          end

        attr_accessor :dest_dir

      end

      def server
        @server ||= if Chef::Config.chef_server_root.nil?
                      ui.warn("chef_server_root not found in knife configuration; using chef_server_url")
                      Chef::Server.from_chef_server_url(Chef::Config.chef_server_url)
                    else
                      Chef::Server.new(Chef::Config.chef_server_root)
                    end
      end

      def rest
        @rest ||= Chef::ServerAPI.new(server.root_url, {:api_version => "0"})
      end

      def set_client_config!
        Chef::Config.custom_http_headers = (Chef::Config.custom_http_headers || {}).merge({'x-ops-request-source' => 'web'})
        Chef::Config.node_name = 'pivotal'
        # Chef::Config.client_key = webui_key
      end
    end
  end
end
