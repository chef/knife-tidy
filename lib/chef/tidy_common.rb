require 'ffi_yajl'
require 'fileutils'
require 'chef/knife/core/ui'

class Chef
  class TidyCommon
    attr_accessor :backup_path

    def initialize(backup_path = Dir.pwd)
      Encoding.default_external = Encoding::UTF_8
      Encoding.default_internal = Encoding::UTF_8
      @backup_path = ::File.expand_path(backup_path)
    end

    def ui
      @ui ||= Chef::Knife::UI.new(STDOUT, STDERR, STDIN, {})
    end

    def users_path
      @users_path ||= ::File.expand_path(::File.join(@backup_path, 'users'))
    end

    def members_path(org)
      ::File.expand_path(::File.join(@backup_path, 'organizations', org, 'members.json'))
    end

    def invitations_path(org)
      ::File.expand_path(::File.join(@backup_path, 'organizations', org, 'invitations.json'))
    end

    def clients_path(org)
      ::File.expand_path(::File.join(@backup_path, 'organizations', org, 'clients'))
    end

    def groups_path(org)
      ::File.expand_path(::File.join(@backup_path, 'organizations', org, 'groups'))
    end

    def org_acls_path(org)
      ::File.expand_path(::File.join(@backup_path, 'organizations', org, 'acls'))
    end

    def user_acls_path
      @user_acls_path ||= ::File.expand_path(::File.join(@backup_path, 'user_acls'))
    end

    def cookbooks_path(org)
      ::File.expand_path(::File.join(@backup_path, 'organizations', org, 'cookbooks'))
    end

    def roles_path(org)
      ::File.expand_path(::File.join(@backup_path, 'organizations', org, 'roles'))
    end

    def org_path(org)
      ::File.expand_path(::File.join(@backup_path, 'organizations', org))
    end

    def unique_email
      (0...8).map { (65 + rand(26)).chr }.join.downcase +
        '@' + (0...8).map { (65 + rand(26)).chr }.join.downcase + '.com'
    end

    def save_user(user)
      ::File.open(::File.join(users_path, "#{user['username']}.json"), 'w+') do |f|
        f.write(FFI_Yajl::Encoder.encode(user, pretty: true))
      end
    end

    def write_new_file(contents, path, backup = true)
      if ::File.exist?(path) && backup
        FileUtils.cp(path, "#{path}.orig") unless ::File.exist?("#{path}.orig")
      end
      ::File.open(path, 'w+') do |f|
        f.write(FFI_Yajl::Encoder.encode(contents, pretty: true))
      end
    end

    def cookbook_name_from_path(path)
      ::File.basename(path, '-*')
    end

    def global_user_names
      @global_user_names ||= Dir[::File.join(@backup_path, 'users', '*')].map { |dir| ::File.basename(dir, '.json') }
    end

    def reports_dir
      @reports_dir ||= ::File.join(Dir.pwd, 'reports')
    end
  end
end
