require 'ffi_yajl'
require 'fileutils'
require 'chef/log'

class Chef
  class TidyOrgAcls
    attr_accessor :members, :clients, :groups, :users

    def initialize(tidy, org)
      @tidy = tidy
      @backup_path = @tidy.backup_path
      @org = org
      @clients = []
      @members = []
      @groups = []
      @users = []
      load_actors
    end

    def load_users
      @tidy.ui.stdout.puts 'INFO: Loading users'
      Dir[::File.join(@tidy.users_path, '*.json')].each do |user|
        @users.push(FFI_Yajl::Parser.parse(::File.read(user), symbolize_names: true))
      end
    end

    def load_members
      @tidy.ui.stdout.puts "INFO: Loading members for #{@org}"
      @members = FFI_Yajl::Parser.parse(::File.read(@tidy.members_path(@org)), symbolize_names: true)
    end

    def load_clients
      @tidy.ui.stdout.puts "INFO: Loading clients for #{@org}"
      Dir[::File.join(@tidy.clients_path(@org), '*.json')].each do |client|
        @clients.push(FFI_Yajl::Parser.parse(::File.read(client), symbolize_names: true))
      end
    end

    def load_groups
      @tidy.ui.stdout.puts "INFO: Loading groups for #{@org}"
      Dir[::File.join(@tidy.groups_path(@org), '*.json')].each do |group|
        @groups.push(FFI_Yajl::Parser.parse(::File.read(group), symbolize_names: true))
      end
    end

    def load_actors
      load_users
      load_members
      load_clients
      load_groups
      @tidy.ui.stdout.puts "INFO: #{@org} Actors loaded!"
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
      !@members.select { |user| user[:user][:username] == actor }.empty?
    end

    def valid_org_client?(actor)
      !@clients.select { |client| client[:name] == actor }.empty?
    end

    def valid_global_user?(actor)
      !@users.select { |user| user[:username] == actor }.empty?
    end

    def invalid_group?(actor)
      @groups.select { |group| group[:name] == actor }.empty? &&
        actor != '::server-admins' &&
        actor != "::#{@org}_read_access_group"
    end

    def ambiguous_actor?(actor)
      valid_org_member?(actor) && valid_org_client?(actor)
    end

    def missing_from_members?(actor)
      valid_global_user?(actor) && !valid_org_member?(actor) && !valid_org_client?(actor)
    end

    def missing_org_client?(actor)
      !valid_global_user?(actor) && !valid_org_member?(actor) && !valid_org_client?(actor)
    end

    def org_acls
      @org_acls ||= Dir[::File.join(@tidy.org_acls_path(@org), '**.json')] +
                    Dir[::File.join(@tidy.org_acls_path(@org), '**', '*.json')]
    end

    def fix_ambiguous_actor(actor)
      @tidy.ui.stdout.puts "REPAIRING: Ambiguous actor! #{actor} removing from #{@tidy.members_path(@org)}"
      remove_user_from_org(actor)
    end

    def add_client_to_org(actor)
      # TODO
      @tidy.ui.stdout.puts "ACTION NEEDED: Client referenced in acl non-existant: #{actor}"
    end

    def add_actor_to_members(actor)
      @tidy.ui.stdout.puts "REPAIRING: Invalid actor: #{actor} adding to #{@tidy.members_path(@org)}"
      user = { user: { username: actor } }
      @members.push(user)
      @tidy.write_new_file(@members, @tidy.members_path(@org))
    end

    def remove_user_from_org(actor)
      @members.reject! { |user| user[:user][:username] == actor }
      @tidy.write_new_file(@members, @tidy.members_path(@org))
    end

    def remove_group_from_acl(group, acl_file)
      @tidy.ui.stdout.puts "REPAIRING: Removing invalid group: #{group} from #{acl_file}"
      acl = FFI_Yajl::Parser.parse(::File.read(acl_file), symbolize_names: false)
      acl_ops.each do |op|
        acl[op]['groups'].reject! { |the_group| the_group == group }
      end
      @tidy.write_new_file(acl, acl_file)
    end

    # Appends the proper acls for ::server-admins and the org's read access group if they are missing.
    def ensure_global_group_acls(acl_file)
      acl = FFI_Yajl::Parser.parse(::File.read(acl_file), symbolize_names: false)
      acl_ops.each do |op|
        unless acl[op]['groups'].include? '::server-admins'
          @tidy.ui.stdout.puts "REPAIRING: Adding #{op} acl for ::server-admins in #{acl_file}"
          acl[op]['groups'].push('::server-admins')
        end
        if op == 'read' && !acl[op]['groups'].include?("::#{@org}_read_access_group")
          @tidy.ui.stdout.puts "REPAIRING: Adding #{op} acl for ::#{@org}_read_access_group in #{acl_file}"
          acl[op]['groups'].push("::#{@org}_read_access_group")
        end
      end
      @tidy.write_new_file(acl, acl_file)
    end

    def ensure_client_read_acls(acl_file)
      acl = FFI_Yajl::Parser.parse(::File.read(acl_file), symbolize_names: false)
      %w(users admins).each do |group|
        unless acl['read']['groups'].include? group
          @tidy.ui.stdout.puts "REPAIRING: Adding read acl for #{group} in #{acl_file}"
          acl['read']['groups'].push(group)
        end
      end
      @tidy.write_new_file(acl, acl_file)
    end

    def validate_acls
      org_acls.each do |acl_file|
        acl = FFI_Yajl::Parser.parse(::File.read(acl_file), symbolize_names: false)
        actors_groups = acl_actors_groups(acl)
        actors_groups[:actors].each do |actor|
          next if actor == 'pivotal'
          if ambiguous_actor?(actor)
            fix_ambiguous_actor(actor)
          elsif missing_from_members?(actor)
            add_actor_to_members(actor)
          elsif missing_org_client?(actor)
            add_client_to_org(actor)
          end
        end
        actors_groups[:groups].each do |group|
          remove_group_from_acl(group, acl_file) if invalid_group?(group)
        end
      end
    end

    def default_user_acl(client)
      { create: { actors: ['pivotal', client], groups: ['::server-admins'] },
        read: { actors: ['pivotal', client], groups: ['::server-admins', "::#{@org}_read_access_group"] },
        update: { actors: ['pivotal', client], groups: ['::server-admins'] },
        delete: { actors: ['pivotal', client], groups: ['::server-admins'] },
        grant: { actors: ['pivotal', client], groups: ['::server-admins'] } }
    end

    def default_client_acl(client_name)
      { create: { actors: ['pivotal', "#{@org}-validator", client_name], groups: ['admins'] },
        read: { actors: ['pivotal', "#{@org}-validator", client_name], groups: %w(admins users) },
        update: { actors: ['pivotal', client_name], groups: ['admins'] },
        delete: { actors: ['pivotal', client_name], groups: %w(admins users) },
        grant: { actors: ['pivotal', client_name], groups: ['admins'] } }
    end

    def validate_user_acls
      @members.each do |member|
        user_acl_path = ::File.join(@tidy.user_acls_path, "#{member[:user][:username]}.json")
        begin
          user_acl = FFI_Yajl::Parser.parse(::File.read(user_acl_path), symbolize_names: false)
        rescue Errno::ENOENT
          @tidy.ui.stdout.puts "REPAIRING: Replacing missing user acl for #{member[:user][:username]}."
          @tidy.write_new_file(default_user_acl(member), user_acl_path, backup = false)
          user_acl = FFI_Yajl::Parser.parse(::File.read(user_acl_path), symbolize_names: false)
        end
        ensure_global_group_acls(user_acl_path)
        actors_groups = acl_actors_groups(user_acl)
        actors_groups[:groups].each do |group|
          remove_group_from_acl(group, user_acl_path) if invalid_group?(group)
        end
      end
    end

    def validate_client_acls
      @clients.each do |client|
        client_acl_path = ::File.join(@tidy.org_acls_path(@org), 'clients', "#{client[:name]}.json")
        begin
          client_acl = FFI_Yajl::Parser.parse(::File.read(client_acl_path), symbolize_names: false)
        rescue Errno::ENOENT
          @tidy.ui.stdout.puts "REPAIRING: Replacing missing client acl for #{client[:name]} in #{client_acl_path}."
          @tidy.write_new_file(default_client_acl(client[:name]), client_acl_path, backup = false)
          client_acl = FFI_Yajl::Parser.parse(::File.read(client_acl_path), symbolize_names: false)
        end
        ensure_client_read_acls(client_acl_path)
      end
    end
  end
end
