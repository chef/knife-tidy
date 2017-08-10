require 'chef/knife/tidy_base'

class Chef
  class Knife
    class TidyBackupClean < Knife

      include Knife::TidyBase

      deps do
        require 'chef/cookbook_loader'
        require 'chef/cookbook/metadata'
        require 'chef/tidy_substitutions'
      end

      option :backup_path,
        :long => '--backup-path path/to/backup',
        :description => 'The path to the knife-ec-backup backup directory'

      option :gsub_file,
        :long => '--gsub-file path/to/gsub/file',
        :description => 'The path to the file used for substitutions'

      def run
        unless config[:backup_path]
          ui.error 'Must specify --backup-path'
          exit 1
        end

        if config[:gsub_file]
          if config[:gen_gsub_template]
            Chef::TidySubstitutions.new(substitutions_file).boiler_plate
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
        ui.info "   Generating new metadata.json for #{path}"
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
    end
  end
end
