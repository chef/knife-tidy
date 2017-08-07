require 'chef/knife/tidy_base'

class Chef
  class Knife
    class TidyBackupReport < Knife

      include Knife::TidyBase

      deps do
        require 'uri'
      end

      banner "knife tidy backup report (OPTIONS)"

      option :node_threshold,
        :long => '--node-threshold NUM_DAYS',
        :default => 30,
        :description => 'Maximum number of days since last checkin before node is marked stale (default: 30)'

      def run
      end
    end
  end
end
