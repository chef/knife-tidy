$:.unshift File.expand_path('../../lib', __FILE__)
require 'chef'
require 'chef/knife/tidy_base'
require 'chef/knife/tidy_backup_clean'
require 'chef/knife/tidy_server_report'
require 'chef/knife/tidy_server_clean'

# Clear config between each example
# to avoid dependencies between examples
RSpec.configure do |c|
  c.raise_errors_for_deprecations!
  c.filter_run_excluding :exclude => true
  c.before(:each) do
    Chef::Config.reset
    Chef::Config[:knife] ={}
  end
end
