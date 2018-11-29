module Cts
  module Mpx
    # responsible for low level calls to MPX
    module Driver
      module_function

      # path to our gem directory, includes support for bundled env's.
      # @return [String] full path to the root of our gem directory.
      def gem_dir
        return Dir.pwd unless Gem.loaded_specs.include? 'cts-mpx'

        Gem.loaded_specs['cts-mpx'].full_gem_path
      end

      # path to our config files
      # @return [String] full path to the root of our gem directory.
      def config_dir
        "#{gem_dir}/config"
      end

      # load a json file into a simple hash
      # @param [String] filename filename to load
      # @raise [RuntimeError] if the filename does not exist.
      # @raise [RuntimeError] if the file cannot be parsed, supplies the exception.
      # @return [Hash] data from the file
      def load_json_file(filename)
        raise "#{filename} does not exist" unless File.exist? filename

        begin
          Oj.load File.read filename
        rescue Oj::ParseError => exception
          raise "#{filename}: #{exception.message}"
        end
      end
    end
  end
end
