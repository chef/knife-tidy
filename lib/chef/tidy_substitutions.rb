require 'ffi_yajl'
require 'tempfile'
require 'fileutils'
require 'chef/log'

class Chef
  class TidySubstitutions
    class NoSubstitutionFile < RuntimeError; end

    attr_accessor :file_path, :backup_path, :data

    def initialize(file_path = nil, backup_path = nil)
      @file_path = file_path
      @backup_path = backup_path
    end

    # Load the substitutions from disk
    #
    # @return [Hash]
    #
    def load_data
      Chef::Log.info "Loading substitutions from #{file_path}"
      @data = FFI_Yajl::Parser.parse(::File.read(@file_path), symbolize_names: false)
    rescue Errno::ENOENT
      raise NoSubstitutionFile, file_path
    end

    def boiler_plate

    end

    def cookbook_version_from_path(path)
      components = path.split(File::SEPARATOR)
      name_version = components[components.index('cookbooks')+1]
      name_version.match(/\d+\.\d+\.\d+/).to_s
    end

    def revert

    end

    def sub_in_file(path, search, replace)
      temp_file = Tempfile.new('tidy')
      begin
        File.open(path, 'r') do |file|
          file.each_line do |line|
            if line.match(search)
              temp_file.puts replace
              Chef::Log.info "  ++ #{path}"
            else
              temp_file.puts line
            end
          end
        end
        temp_file.close
        FileUtils.mv(path, "#{path}.orig") unless ::File.exist?("#{path}.orig")
        FileUtils.mv(temp_file.path, path)
      ensure
        temp_file.close
        temp_file.unlink
      end
    end

    def run_substitutions
      load_data
      @data.keys.each do |entry|
        @data[entry].keys.each do |glob|
          Chef::Log.info "Running substitutions for #{entry} -> #{glob}"
          Dir[::File.join(backup_path, glob)].each do |file|
            @data[entry][glob].each do |substitution|
              search = Regexp.new(substitution['pattern'])
              replace = substitution['replace'].dup
              replace.gsub!(/\!COOKBOOK_VERSION\!/) { |m| "'" + cookbook_version_from_path(file) + "'" }
              sub_in_file(file, search, replace)
            end
          end
        end
      end
    end
  end
end
