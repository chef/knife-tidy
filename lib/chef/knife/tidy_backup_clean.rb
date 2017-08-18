require 'chef/knife/tidy_base'

class Chef
  class Knife
    class TidyBackupClean < Knife

      deps do
        require 'chef/cookbook_loader'
        require 'chef/cookbook/metadata'
        require 'chef/tidy_substitutions'
        require 'chef/tidy_acls'
        require 'ffi_yajl'
      end

      banner "knife tidy backup clean (OPTIONS)"

      include Knife::TidyBase

      option :backup_path,
        :long => '--backup-path path/to/backup',
        :description => 'The path to the knife-ec-backup backup directory'

      option :gsub_file,
        :long => '--gsub-file path/to/gsub/file',
        :description => 'The path to the file used for substitutions. If non-existant, a boiler plate one will be created.'

      def run
        unless config[:backup_path] && ::File.directory?(config[:backup_path])
          ui.error 'Must specify valid --backup-path'
          exit 1
        end

        validate_user_emails

        if config[:gsub_file]
          unless ::File.exist?(config[:gsub_file])
            Chef::TidySubstitutions.new(substitutions_file).boiler_plate
            exit
          else
            Chef::TidySubstitutions.new(substitutions_file, tidy).run_substitutions
          end
        end

        orgs.each do |org|
          org_acls = Chef::TidyOrgAcls.new(tidy, org)
          org_acls.validate_acls
          org_acls.validate_user_acls
          fix_self_dependencies(org)
          load_cookbooks(org)
          generate_new_metadata(org)
        end
      end

      def validate_user_emails
        emails_seen = []
        tidy.global_user_names.each do |user|
          email = ''
          ui.info "Validating #{user}"
          the_user = FFI_Yajl::Parser.parse(::File.read(::File.join(tidy.users_path, "#{user}.json")), symbolize_names: false)
          if the_user['email'].match(/\A[^@\s]+@[^@\s]+\z/)
            if emails_seen.include?(the_user['email'])
              ui.info "Already saw #{user}'s email, creating a unique one."
              email = tidy.unique_email
              new_user = the_user.dup
              new_user['email'] = email
              tidy.save_user(new_user)
              emails_seen.push(email)
            else
              emails_seen.push(the_user['email'])
            end
          else
            ui.info "User #{user} does not have a valid email, creating a unique one."
            email = tidy.unique_email
            new_user = the_user.dup
            new_user['email'] = email
            tidy.save_user(new_user)
            emails_seen.push(email)
          end
        end
      end

      def load_cookbooks(org)
        cl = Chef::CookbookLoader.new(tidy.cookbooks_path(org))
        for_each_cookbook_basename(org) do |cookbook|
          ui.info "Loading #{cookbook}"
          ret = cl.load_cookbook(cookbook)
          if ret.nil?
            ui.warn "Something's wrong with the #{cookbook} cookbook - cannot load it! Moving to cookbooks.broken folder."
            broken_cookooks_add(org, cookbook)
          end
        end
      rescue LoadError => e
        ui.error e
        ui.error 'Look at the cookbook above and determine what in the metadata.rb is causing the exception and rectify manually'
        exit 1
      end

      def broken_cookooks_add(org, cookbook)
        broken_path = ::File.join(tidy.org_path(org), 'cookbooks.broken')
        FileUtils.mkdir(broken_path) unless ::File.directory?(broken_path)
        Dir[::File.join(tidy.cookbooks_path(org), "#{cookbook}*")].each do |cb|
          FileUtils.mv(cb, broken_path, :verbose => true, :force => true)
        end
      end

      def generate_new_metadata(org)
        for_each_cookbook_path(org) do |cookbook_path|
          generate_metadata_from_file(tidy.cookbook_name_from_path(cookbook_path), cookbook_path)
        end
      end

      def fix_self_dependencies(org)
        for_each_cookbook_path(org) do |cookbook_path|
          name = tidy.cookbook_name_from_path(cookbook_path)
          md_path = ::File.join(cookbook_path, 'metadata.rb')
          unless ::File.exist?(md_path)
            ui.warn "No metadata.rb in #{cookbook_path} - skipping"
            next
          end
          Chef::TidySubstitutions.new.sub_in_file(
            ::File.join(cookbook_path, 'metadata.rb'),
            Regexp.new("^depends +['\"]#{name}['\"]"),
            "# depends '#{name}' # knife-tidy was here")
        end
      end

      def generate_metadata_from_file(cookbook, path)
        md_path = ::File.join(path, 'metadata.rb')
        unless ::File.exist?(md_path)
          ui.warn "No metadata.rb in #{path} - skipping"
          return
        end
        ui.info "Generating new metadata.json for #{path}"
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

      def substitutions_file
        @substitutions_file ||= ::File.expand_path(config[:gsub_file])
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
    end
  end
end
