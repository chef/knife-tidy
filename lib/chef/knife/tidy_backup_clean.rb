require 'chef/knife/tidy_base'

class Chef
  class Knife
    class TidyBackupClean < Knife

      include Knife::TidyBase

      deps do
        require 'chef/cookbook_loader'
        require 'chef/cookbook/metadata'
        require 'chef/tidy_substitutions'
        require 'ffi_yajl'
      end

      option :backup_path,
        :long => '--backup-path path/to/backup',
        :description => 'The path to the knife-ec-backup backup directory'

      option :gsub_file,
        :long => '--gsub-file path/to/gsub/file',
        :description => 'The path to the file used for substitutions. If non-existant, a boiler plate one will be created.'

      def run
        unless config[:backup_path]
          ui.error 'Must specify --backup-path'
          exit 1
        end

        validate_user_emails!

        if config[:gsub_file]
          unless ::File.exist?(config[:gsub_file])
            Chef::TidySubstitutions.new(substitutions_file).boiler_plate
            exit
          else
            Chef::TidySubstitutions.new(substitutions_file, backup_path_expanded).run_substitutions
          end
        end

        orgs.each do |org|
          fix_self_dependencies(org)
          load_cookbooks(org)
          generate_new_metadata(org)
        end
      end

      def validate_user_emails!
        emails_seen = []
        global_users.each do |user|
          email = ''
          ui.info "Validating #{user}"
          the_user = FFI_Yajl::Parser.parse(::File.read(::File.join(global_users_path_expanded, "#{user}.json")), symbolize_names: false)
          if the_user['email'].match(/\A[^@\s]+@[^@\s]+\z/)
            if emails_seen.include?(the_user['email'])
              ui.info "Already saw #{user}'s email, creating a unique one."
              email = unique_email
              new_user = the_user.dup
              new_user['email'] = email
              save_user(new_user)
              emails_seen.push(email)
            else
              emails_seen.push(the_user['email'])
            end
          else
            ui.info "User #{user} does not have a valid email, creating a unique one."
            email = unique_email
            new_user = the_user.dup
            new_user['email'] = email
            save_user(new_user)
            emails_seen.push(email)
          end
        end
      end

      def unique_email
        (0...8).map { (65 + rand(26)).chr }.join.downcase +
        '@' + (0...8).map { (65 + rand(26)).chr }.join.downcase + '.com'
      end

      def save_user(user)
        ::File.open(::File.join(global_users_path_expanded, "#{user['username']}.json"), 'w+') do |f|
          f.write(FFI_Yajl::Encoder.encode(user, pretty: true))
        end
      end

      def load_cookbooks(org)
        cl = Chef::CookbookLoader.new(cookbooks_path_expanded(org))
        for_each_cookbook_basename(org) do |cookbook|
          ui.info "Loading #{cookbook}"
          ret = cl.load_cookbook(cookbook)
          if ret.nil?
            ui.error "Something's wrong with the #{cookbook} cookbook - cannot load it!"
          end
        end
      rescue LoadError => e
        ui.error e
        ui.error 'Look at the cookbook above and determine what in the metadata.rb is causing the exception and rectify manually'
        exit 1
      end

      def generate_new_metadata(org)
        for_each_cookbook_path(org) do |cookbook_path|
          generate_metadata_from_file(cookbook_name_from_path(cookbook_path), cookbook_path)
        end
      end

      def fix_self_dependencies(org)
        for_each_cookbook_path(org) do |cookbook_path|
          name = cookbook_name_from_path(cookbook_path)
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

      def validate_user(user)
        ui.info "Validating user #{user}"
      end
    end
  end
end
