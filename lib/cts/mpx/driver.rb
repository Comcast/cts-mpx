module Cts
  module Mpx
    # responsible for low level calls to MPX
    module Driver
      module_function

      # used when the token has a problem
      class TokenError < RuntimeError
      end

      # used when the login credentials are incorrect
      class CredentialsError < RuntimeError
      end

      # used when the services cannot be communicated with
      class ConnectionError < RuntimeError
      end

      # used when the service returns an exception
      class ServiceError < RuntimeError
      end

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
      def parse_json(string)
        Oj.compat_load string
      rescue Oj::ParseError => exception
        raise "#{string}: #{exception.message}"
      end
    end
  end
end
