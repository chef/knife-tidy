require 'ffi_yajl'
require 'tempfile'
require 'fileutils'
require 'chef/log'

class Chef
  class TidySubstitutions
    class NoSubstitutionFile < RuntimeError; end

    attr_accessor :file_path, :backup_path, :data

    def initialize(file_path = nil, tidy_common)
      @file_path = file_path
      @tidy = tidy_common
      @backup_path = tidy_common.backup_path
    end

    def load_data
      @tidy.ui.stdout.puts "INFO: Loading substitutions from #{file_path}"
      @data = FFI_Yajl::Parser.parse(::File.read(@file_path), symbolize_names: false)
    rescue Errno::ENOENT
      raise NoSubstitutionFile, file_path
    end

    def boiler_plate
      bp = ::File.join(File.dirname(__FILE__), '../../conf/substitutions.json.example')
      @tidy.ui.stdout.puts "INFO: Creating boiler plate gsub file: 'substitutions.json'"
      FileUtils.cp(bp, ::File.join(Dir.pwd, 'substitutions.json'))
    end

    def cookbook_version_from_path(path)
      components = path.split(File::SEPARATOR)
      name_version = components[components.index('cookbooks') + 1]
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
              @tidy.ui.stdout.puts "INFO:  ++ #{path}"
            else
              temp_file.puts line
            end
          end
        end
        temp_file.close
        FileUtils.cp(path, "#{path}.orig") unless ::File.exist?("#{path}.orig")
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
          @tidy.ui.stdout.puts "INFO: Running substitutions for #{entry} -> #{glob}"
          Dir[::File.join(@backup_path, glob)].each do |file|
            @data[entry][glob].each do |substitution|
              search = Regexp.new(substitution['pattern'])
              replace = substitution['replace'].dup
              replace.gsub!(/\!COOKBOOK_VERSION\!/) { |_m| "'" + cookbook_version_from_path(file) + "'" }
              sub_in_file(file, search, replace)
            end
          end
        end
      end
    end
  end
end
