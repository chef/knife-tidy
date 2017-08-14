require 'ffi_yajl'
require 'tempfile'
require 'fileutils'
require 'chef/log'

class Chef
  class TidyOrgAcls
    attr_accessor :members, :clients, :groups, :users

    def initialize(backup_path, org)
      @backup_path = backup_path
      @org = org
      @clients = []
      @members = []
      @groups = []
      @users = []
      load_actors
    end

    def users_path
      @users_path ||= ::File.expand_path(::File.join(@backup_path, 'users'))
    end

    def members_path
      @members_path ||= ::File.expand_path(::File.join(@backup_path, 'organizations', @org, 'members.json'))
    end

    def clients_path
      @clients_path ||= ::File.expand_path(::File.join(@backup_path, 'organizations', @org, 'clients'))
    end

    def groups_path
      @groups_path ||= ::File.expand_path(::File.join(@backup_path, 'organizations', @org, 'groups'))
    end

    def acls_path
      @acls_path ||= ::File.expand_path(::File.join(@backup_path, 'organizations', @org, 'acls'))
    end

    def load_users
      Chef::Log.info "Loading users"
      Dir[::File.join(users_path, '*.json')].each do |user|
        @users.push(FFI_Yajl::Parser.parse(::File.read(user), symbolize_names: true))
      end
    end

    def load_members
      Chef::Log.info "Loading members for #{@org}"
      @members = FFI_Yajl::Parser.parse(::File.read(members_path), symbolize_names: true)
    end

    def load_clients
      Chef::Log.info "Loading clients for #{@org}"
      Dir[::File.join(clients_path, '*.json')].each do |client|
        @clients.push(FFI_Yajl::Parser.parse(::File.read(client), symbolize_names: true))
      end
    end

    def load_groups
      Chef::Log.info "Loading groups for #{@org}"
      Dir[::File.join(groups_path, '*.json')].each do |group|
        @groups.push(FFI_Yajl::Parser.parse(::File.read(group), symbolize_names: true))
      end
    end

    def load_actors
      load_users
      load_members
      load_clients
      load_groups
      Chef::Log.info "#{@org} Actors loaded!"
    end

    def acl_ops
      %w( create read update delete grant )
    end

    def acl_actors_groups(acl)
      actors_seen = []
      groups_seen = []
      acl_ops.each do |op|
        acl[op]['actors'].each do |actor|
          actors_seen.push(actor) unless actors_seen.include?(actor)
        end
        acl[op]['groups'].each do |group|
          groups_seen.push(group) unless groups_seen.include?(group)
        end
      end
      { actors: actors_seen, groups: groups_seen }
    end

    def valid_org_member?(actor)
      ! @members.select { |user| user[:user][:username] == actor }.empty?
    end

    def valid_org_client?(actor)
      ! @clients.select { |client| client[:name] == actor }.empty?
    end

    def valid_global_user?(actor)
      ! @users.select { |user| user[:username] == actor }.empty?
    end

    def invalid_group?(actor)
      @groups.select { |group| group[:name] == actor }.empty?
    end

    def ambiguous_actor?(actor)
      valid_global_user?(actor) && valid_org_client?(actor)
    end

    def missing_from_members?(actor)
      valid_global_user?(actor) && !valid_org_member?(actor) && !valid_org_client?(actor)
    end

    def missing_org_client?(actor)
      !valid_global_user?(actor) && !valid_org_member?(actor) && !valid_org_client?(actor)
    end

    def org_acls
      @org_acls ||= Dir[::File.join(acls_path, '**.json')] +
                      Dir[::File.join(acls_path, '**', '*.json')]
    end

    def fix_ambiguous_actor(actor)
      Chef::Log.warn "Ambiguous actor! #{actor}"
    end

    def add_client_to_org(actor)
      Chef::Log.warn "Client referenced in acl non-existant: #{actor}"
    end

    def add_actor_to_members(actor)
      Chef::Log.warn "Invalid actor: #{actor} adding to #{members_path}"
      user = { 'user' => { 'username' => actor } }
      temp_members = @members.dup
      temp_members.push(user)
      FileUtils.cp(members_path, "#{members_path}.orig") unless ::File.exist?("#{members_path}.orig")
      ::File.open(members_path, 'w+') do |f|
         f.write(FFI_Yajl::Encoder.encode(temp_members, pretty: true))
      end
      load_members
    end

    def fix_missing_group(group)
      Chef::Log.warn "Fixing invalid group: #{group}"
    end

    def validate_acls
      org_acls.each do |acl_file|
        acl = FFI_Yajl::Parser.parse(::File.read(acl_file), symbolize_names: false)
        actor_groups = acl_actors_groups(acl)
        actor_groups[:actors].each do |actor|
          next if actor == 'pivotal'
          if ambiguous_actor?(actor)
            fix_ambiguous_actor(actor)
          elsif missing_from_members?(actor)
            add_actor_to_members(actor)
          elsif missing_org_client?(actor)
            add_client_to_org(actor)
          end
        end
        actor_groups[:groups].each do |group|
          if invalid_group?(group)
            fix_missing_group(group)
          end
        end
      end
    end
  end
end

acl = Chef::TidyOrgAcls.new('/Users/jmiller/Downloads/backup', 'gtms')
acl.validate_acls

#require 'pry';binding.pry

puts "foo"
