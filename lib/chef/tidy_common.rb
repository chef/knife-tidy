require "ffi_yajl"
require "fileutils"
require "chef/knife/core/ui"

class Chef
  class TidyCommon
    attr_accessor :backup_path

    def initialize(backup_path = Dir.pwd)
      Encoding.default_external = Encoding::UTF_8
      Encoding.default_internal = Encoding::UTF_8
      @backup_path = ::File.expand_path(backup_path)
    end

    #
    # @return [Chef::Knife::UI]
    #
    def ui
      @ui ||= Chef::Knife::UI.new(STDOUT, STDERR, STDIN, {})
    end

    # The path to the users directory in the backup
    #
    # @return [String]
    #
    def users_path
      @users_path ||= ::File.expand_path(::File.join(@backup_path, "users"))
    end

    # The path to the members.json file in the backup
    #
    # @param [String] org
    #
    # @return [String]
    #
    def members_path(org)
      ::File.expand_path(::File.join(@backup_path, "organizations", org, "members.json"))
    end

    # The path to the invitations.json file in the backup
    #
    # @param [String] org
    #
    # @return [String]
    #
    def invitations_path(org)
      ::File.expand_path(::File.join(@backup_path, "organizations", org, "invitations.json"))
    end

    # The path to the clients directory in the backup
    #
    # @param [String] org
    #
    # @return [String]
    #
    def clients_path(org)
      ::File.expand_path(::File.join(@backup_path, "organizations", org, "clients"))
    end

    # The paths to each of the client json files in the backup
    #
    # @param [String] org
    #
    # @return [Array]
    #
    def client_names(org)
      Dir[::File.join(clients_path(org), "*")].map { |dir| ::File.basename(dir, ".json") }
    end

    # The path to groups directory in the backup
    #
    # @param [String] org
    #
    # @return [String]
    #
    def groups_path(org)
      ::File.expand_path(::File.join(@backup_path, "organizations", org, "groups"))
    end

    # The path to acls directory in the backup
    #
    # @param [String] org
    #
    # @return [String]
    #
    def org_acls_path(org)
      ::File.expand_path(::File.join(@backup_path, "organizations", org, "acls"))
    end

    # The path to user_acls directory in the backup
    #
    # @return [String]
    #
    def user_acls_path
      @user_acls_path ||= ::File.expand_path(::File.join(@backup_path, "user_acls"))
    end

    # The path to cookbooks directory in the backup
    #
    # @param [String] org
    #
    # @return [String]
    #
    def cookbooks_path(org)
      ::File.expand_path(::File.join(@backup_path, "organizations", org, "cookbooks"))
    end

    # The path to roles directory in the backup
    #
    # @param [String] org
    #
    # @return [String]
    #
    def roles_path(org)
      ::File.expand_path(::File.join(@backup_path, "organizations", org, "roles"))
    end

    # The path to the org directory in the backup
    #
    # @param [String] org
    #
    # @return [String]
    #
    def org_path(org)
      ::File.expand_path(::File.join(@backup_path, "organizations", org))
    end

    # generate a bogus, but valid email
    #
    # @return [String]
    #
    def unique_email
      (0...8).map { (65 + rand(26)).chr }.join.downcase +
        "@" + (0...8).map { (65 + rand(26)).chr }.join.downcase + ".com"
    end

    def save_user(user)
      ::File.open(::File.join(users_path, "#{user['username']}.json"), "w+") do |f|
        f.write(FFI_Yajl::Encoder.encode(user, pretty: true))
      end
    end

    def write_new_file(contents, path, backup = true)
      if ::File.exist?(path) && backup
        FileUtils.cp(path, "#{path}.orig") unless ::File.exist?("#{path}.orig")
      end
      ::File.open(path, "w+") do |f|
        f.write(FFI_Yajl::Encoder.encode(contents, pretty: true))
      end
    end

    #
    # Determine the cookbook name from path
    #
    # @param [String] path The path of the cookbook.
    #
    # @return [String] The cookbook's name
    #
    # @example
    # cookbook_version_from_path('/data/chef_backup/snapshots/20191008040001/organizations/myorg/cookbooks/chef-sugar-5.0.4') => 'chef-sugar'
    #
    def cookbook_name_from_path(path)
      ::File.basename(path, "-*")
    end

    #
    # Determine the cookbook version from a path.
    #
    # @param [String] path The path of the cookbook.
    #
    # @return [String] The version of the cookbook.
    #
    # @example
    # cookbook_version_from_path('/data/chef_backup/snapshots/20191008040001/organizations/myorg/cookbooks/chef-sugar-5.0.4') => '5.0.4'
    #
    def cookbook_version_from_path(path)
      ::File.basename(path).match(/\d+\.\d+\.\d+/).to_s
      name_version.match(/\d+\.\d+\.\d+/).to_s
    end

    def global_user_names
      @global_user_names ||= Dir[::File.join(@backup_path, "users", "*")].map { |dir| ::File.basename(dir, ".json") }
    end

    def reports_dir
      @reports_dir ||= ::File.join(Dir.pwd, "reports")
    end
  end
end
