require 'chef/knife/tidy_base'

class Chef
  class Knife
    class TidyBackupClean < Knife
      deps do
        require 'chef/cookbook_loader'
        require 'chef/cookbook/metadata'
        require 'chef/role'
        require 'chef/run_list'
        require 'chef/tidy_substitutions'
        require 'chef/tidy_acls'
        require 'ffi_yajl'
        require 'fileutils'
        require 'securerandom'
      end

      banner 'knife tidy backup clean (options)'

      include Knife::TidyBase

      option :backup_path,
        long: '--backup-path path/to/backup',
        description: 'The path to the knife-ec-backup backup directory'

      option :gsub_file,
        long: '--gsub-file path/to/gsub/file',
        description: 'The path to the file used for substitutions. If non-existant, a boiler plate one will be created.'

      option :gen_gsub,
        long: '--gen-gsub',
        description: 'Generate a new boiler plate global substitutions file: \'substitutions.json\'.'

      def run
        FileUtils.rm_f(action_needed_file_path)

        if config[:gen_gsub]
          Chef::TidySubstitutions.new(nil, tidy).boiler_plate
          exit
        end

        unless config[:backup_path] && ::File.directory?(config[:backup_path])
          ui.error 'Must specify valid --backup-path'
          exit 1
        end

        fix_chef_sugar_metadata

        Chef::TidySubstitutions.new(substitutions_file, tidy).run_substitutions if config[:gsub_file]

        validate_user_emails

        orgs.each do |org|
          fix_org_object(org)
          validate_invitations(org)
          validate_roles(org)
          org_acls = Chef::TidyOrgAcls.new(tidy, org)
          org_acls.validate_acls
          org_acls.validate_user_acls
          org_acls.validate_client_acls
          fix_self_dependencies(org)
          fix_cookbook_names(org)
          generate_new_metadata(org)
          load_cookbooks(org)
        end

        completion_message

        ui.stdout.puts "\nWARNING: ** Unrepairable Items **\nPlease see #{action_needed_file_path}\n" if ::File.exist?(action_needed_file_path)
      end

      def validate_user_emails
        emails_seen = []
        tidy.global_user_names.each do |user|
          email = ''
          ui.stdout.puts "INFO: Validating #{user}"
          the_user = FFI_Yajl::Parser.parse(::File.read(::File.join(tidy.users_path, "#{user}.json")), symbolize_names: false)
          if the_user.key?('email') && the_user['email'].match(/\A[^@\s]+@[^@\s]+\z/)
            if emails_seen.include?(the_user['email'])
              ui.stdout.puts "REPAIRING: Already saw #{user}'s email, creating a unique one."
              email = tidy.unique_email
              new_user = the_user.dup
              new_user['email'] = email
              tidy.save_user(new_user)
              emails_seen.push(email)
            else
              emails_seen.push(the_user['email'])
            end
          else
            ui.stdout.puts "REPAIRING: User #{user} does not have a valid email, creating a unique one."
            email = tidy.unique_email
            new_user = the_user.dup
            new_user['email'] = email
            tidy.save_user(new_user)
            emails_seen.push(email)
          end
        end
      end

      # In Chef Server 12 an org object should have exactly 3 keys: name, full_name and guid
      # The existence of anything else will cause a restore to fail
      # EC11 backups will contain org objects with 6 extra fields including org_type, billing_plan, assigned_at, etc
      def fix_org_object(org)
        ui.stdout.puts "INFO: Validating org object for #{org}"
        org_object = load_org_object(org)

        unless org_object.keys.count == 3 # cheapo, maybe expect the exact names?
          ui.stdout.puts "REPAIRING: org object for #{org} contains extra/missing fields. Fixing that for you"
          # quick/dirty attempt at fixing any of the required fields in case they're nil
          good_name = org_object['name'] || org
          good_full_name = org_object['full_name'] || org
          good_guid = org_object['guid'] || SecureRandom.uuid.delete('-')
          fixed_org_object = { name: good_name, full_name: good_full_name, guid: good_guid }

          write_org_object(org, fixed_org_object)
        end
      end

      def load_org_object(org)
        JSON.parse(File.read(File.join(tidy.org_path(org), 'org.json')))
      rescue Errno::ENOENT, JSON::ParserError
        ui.stdout.puts "REPAIRING: org object for organization #{org} is missing or corrupt. Generating a new one"
        return { name: org, full_name: org, guid: SecureRandom.uuid.delete('-') }
      end

      def write_org_object(org, org_object)
        File.write(File.join(tidy.org_path(org), 'org.json'), JSON.pretty_generate(org_object))
      end

      def add_cookbook_name_to_metadata(cookbook_name, rb_path)
        ui.stdout.puts "REPAIRING: Correcting `name` in #{rb_path}"
        content = IO.readlines(rb_path)
        new_content = content.reject { |line| line =~ /^name\s+/ }
        name_field = "name '#{cookbook_name}'\n"
        IO.write rb_path, name_field + new_content.join('')
      end

      def fix_cookbook_names(org)
        for_each_cookbook_path(org) do |cookbook_path|
          rb_path = ::File.join(cookbook_path, 'metadata.rb')
          json_path = ::File.join(cookbook_path, 'metadata.json')
          # next unless ::File.exist?(rb_path)
          cookbook_name = tidy.cookbook_name_from_path(cookbook_path)
          if ::File.exist?(rb_path)
            lines = ::File.readlines(rb_path).select { |line| line =~ /^name.*['"]#{cookbook_name}['"]/ }
            add_cookbook_name_to_metadata(cookbook_name, rb_path) if lines.empty?
          else
            if ::File.exist?(json_path)
              metadata = FFI_Yajl::Parser.parse(::File.read(json_path), symbolize_names: false)
              if metadata['name'] != cookbook_name
                metadata['name'] = cookbook_name
                ui.stdout.puts "REPAIRING: Correcting `name` in #{json_path}`"
                ::File.open(json_path, 'w') do |f|
                  f.write(Chef::JSONCompat.to_json_pretty(metadata))
                end
              end
            end
          end
        end
      end

      def load_cookbooks(org)
        cl = Chef::CookbookLoader.new(tidy.cookbooks_path(org))
        for_each_cookbook_basename(org) do |cookbook|
          ui.stdout.puts "INFO: Loading #{cookbook}"
          ret = cl.load_cookbook(cookbook)
          if ret.nil?
            action_needed("ACTION NEEDED: Something's wrong with the #{cookbook} cookbook in org #{org} - cannot load it! Moving to cookbooks.broken folder.")
            broken_cookooks_add(org, cookbook)
          end
        end
      rescue LoadError => e
        ui.error e
        exit 1
      end

      def broken_cookooks_add(org, cookbook)
        broken_path = ::File.join(tidy.org_path(org), 'cookbooks.broken')
        FileUtils.mkdir(broken_path) unless ::File.directory?(broken_path)
        Dir[::File.join(tidy.cookbooks_path(org), "#{cookbook}*")].each do |cb|
          FileUtils.mv(cb, broken_path, verbose: true, force: true)
        end
      end

      def generate_new_metadata(org)
        for_each_cookbook_path(org) do |cookbook_path|
          generate_metadata_from_file(tidy.cookbook_name_from_path(cookbook_path), cookbook_path)
          fix_metadata_fields(cookbook_path)
        end
      end

      def fix_chef_sugar_metadata
        Dir[::File.join(tidy.backup_path, 'organizations/*/cookbooks/chef-sugar*/metadata.rb')].each do |file|
          ui.stdout.puts 'INFO: Searching for known chef-sugar problems when uploading.'
          s = Chef::TidySubstitutions.new(nil, tidy)
          version = s.cookbook_version_from_path(file)
          patterns = [
            {
              search: '^require .*/lib/chef/sugar/version',
              replace: "# require          File.expand_path('../lib/chef/sugar/version', *__FILE__)",
            },
            {
              search: '^version *Chef::Sugar::VERSION',
              replace: "version '#{version}'",
            },
          ]
          patterns.each do |p|
            s.sub_in_file(file, Regexp.new(p[:search]), p[:replace])
          end
        end
      end

      def fix_self_dependencies(org)
        for_each_cookbook_path(org) do |cookbook_path|
          name = tidy.cookbook_name_from_path(cookbook_path)
          md_path = ::File.join(cookbook_path, 'metadata.rb')
          unless ::File.exist?(md_path)
            ui.stdout.puts "INFO: No metadata.rb in #{cookbook_path} - skipping"
            next
          end
          Chef::TidySubstitutions.new(nil, tidy).sub_in_file(
            ::File.join(cookbook_path, 'metadata.rb'),
            Regexp.new("^depends +['\"]#{name}['\"]"),
            "# depends '#{name}' # knife-tidy was here")
        end
      end

      def fix_metadata_fields(cookbook_path)
        json_path = ::File.join(cookbook_path, 'metadata.json')
        metadata = FFI_Yajl::Parser.parse(::File.read(json_path), symbolize_names: false)
        md = metadata.dup
        metadata.each_pair do |key, value|
          if value.nil?
            ui.stdout.puts "REPAIRING: Fixing null value for key #{key} in #{json_path}"
            md[key] = 'default value'
          end
        end
        if metadata.key?('platforms')
          metadata['platforms'].each_pair do |key, value|
            # platform key cannot contain comma delimited values
            md['platforms'].delete(key) if key =~ /,/
            if value.is_a?(Array) && value.empty?
              ui.stdout.puts "REPAIRING: Fixing empty platform key for for key #{key} in #{json_path}"
              md['platforms'][key] = '>= 0.0.0'
            end
          end
        end
        ::File.open(json_path, 'w') do |f|
          f.write(Chef::JSONCompat.to_json_pretty(md))
        end
      end

      def generate_metadata_from_file(cookbook, path)
        md_path = ::File.join(path, 'metadata.rb')
        json_path = ::File.join(path, 'metadata.json')
        if !::File.exist?(md_path) && !::File.exist?(json_path)
          create_minimal_metadata(path)
        end
        unless ::File.exist?(md_path)
          ui.stdout.puts "INFO: No metadata.rb in #{path} - skipping"
          return
        end
        ui.stdout.puts "INFO: Generating new metadata.json for #{path}"
        md = Chef::Cookbook::Metadata.new
        md.name(cookbook)
        md.from_file(md_path)
        json_file = ::File.join(path, 'metadata.json')
        ::File.open(json_file, 'w') do |f|
          f.write(Chef::JSONCompat.to_json_pretty(md))
        end
      rescue Exceptions::ObsoleteDependencySyntax, Exceptions::InvalidVersionConstraint => e
        ui.stderr.puts "ERROR: The cookbook '#{cookbook}' contains invalid or obsolete metadata syntax."
        ui.stderr.puts "in #{file}:"
        ui.stderr.puts
        ui.stderr.puts e.message
        exit 1
      end

      def create_minimal_metadata(cookbook_path)
        name = tidy.cookbook_name_from_path(cookbook_path)
        components = cookbook_path.split(File::SEPARATOR)
        name_version = components[components.index('cookbooks') + 1]
        version = name_version.match(/\d+\.\d+\.\d+/).to_s
        metadata = {}
        metadata['name'] = name
        metadata['version'] = version
        metadata['description'] = 'the description'
        metadata['long_description'] = 'the long description'
        metadata['maintainer'] = 'the maintainer'
        metadata['maintainer_email'] = 'the maintainer email'
        rb_file = ::File.join(cookbook_path, 'metadata.rb')
        ui.stdout.puts "REPAIRING: no metadata files exist for #{cookbook_path}, creating #{rb_file}"
        ::File.open(rb_file, 'w') do |f|
          metadata.each_pair do |key, value|
            f.write("#{key} '#{value}'\n")
          end
        end
      end

      def substitutions_file
        sub_file_path = ::File.expand_path(config[:gsub_file])
        ui.error "Subtitutions file #{sub_file_path} does not exist!" unless ::File.exist?(sub_file_path)
        @substitutions_file ||= sub_file_path
      end

      def orgs
        @orgs ||= if config[:org_list]
                    config[:org_list].split(',')
                  else
                    Dir[::File.join(tidy.backup_path, 'organizations', '*')].map { |dir| ::File.basename(dir) }
                  end
      end

      def for_each_cookbook_basename(org)
        cookbooks_seen = []
        Dir[::File.join(tidy.cookbooks_path(org), '**-**')].each do |cookbook|
          name = tidy.cookbook_name_from_path(cookbook)
          unless cookbooks_seen.include?(name)
            cookbooks_seen.push(name)
            yield name
          end
        end
      end

      def for_each_cookbook_path(org)
        Dir[::File.join(tidy.cookbooks_path(org), '**')].each do |cookbook|
          yield cookbook
        end
      end

      def action_needed_file_path
        ::File.expand_path('knife-tidy-actions-needed.txt')
      end

      def action_needed(msg)
        ::File.open(action_needed_file_path, 'a') do |f|
          f.write(msg + "\n")
        end
      end

      def write_role(path, role)
        ::File.open(path, 'w') do |f|
          f.write(Chef::JSONCompat.to_json_pretty(role))
        end
      end

      def for_each_role(org)
        Dir[::File.join(tidy.roles_path(org), '*.json')].each do |role|
          yield role
        end
      end

      def repair_role_run_lists(role_path)
        the_role = FFI_Yajl::Parser.parse(::File.read(role_path), symbolize_names: false)
        new_role = the_role.clone
        rl = Chef::RunList.new
        new_role['run_list'] = []
        the_role['run_list'].each do |item|
          begin
            rl << item
            new_role['run_list'].push(item)
          rescue ArgumentError
            ui.stdout.puts "REPAIRING: Invalid Recipe Item: #{item} in run_list from #{role_path}"
          end
        end
        if the_role.key?('env_run_lists')
          the_role['env_run_lists'].each_pair do |key, value|
            new_role['env_run_lists'][key] = []
            value.each do |item|
              begin
                rl << item
                new_role['env_run_lists'][key].push(item)
              rescue ArgumentError
                ui.stdout.puts "REPAIRING: Invalid Recipe Item: #{item} in env_run_lists #{key} from #{role_path}"
              end
            end
          end
        end
        write_role(role_path, new_role)
        # rubocop:enable MethodLength
      end

      def validate_roles(org)
        for_each_role(org) do |role_path|
          ui.stdout.puts "INFO: Validating Role at #{role_path}"
          begin
            Chef::Role.from_hash(FFI_Yajl::Parser.parse(::File.read(role_path), symbolize_names: false))
          rescue ArgumentError
            repair_role_run_lists(role_path)
          end
        end
      end

      def validate_invitations(org)
        invite_file = tidy.invitations_path(org)
        ui.stdout.puts "INFO: validating org #{org} invites in #{invite_file}"
        invitations = FFI_Yajl::Parser.parse(::File.read(invite_file), symbolize_names: false)
        invitations_new = []
        invitations.each do |invite|
          if invite['username'].nil?
            ui.stdout.puts "REPAIRING: Dropping corrupt invitations for #{org} in file #{invite_file}"
          else
            invite_hash = {}
            invite_hash['id'] = invite['id']
            invite_hash['username'] = invite['username']
            invitations_new.push(invite_hash)
          end
        end
        ::File.open(invite_file, 'w') do |f|
          f.write(Chef::JSONCompat.to_json_pretty(invitations_new))
        end
      end
    end
  end
end
