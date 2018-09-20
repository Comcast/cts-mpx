module Cts
  module Mpx
    module Driver
      #
      # Container for active connections to the data service.
      #
      module Connections
        module_function

        #
        # Addressable method for active connections.   If you provide a string that is not active, an active one
        # will be created.
        #
        # @param [String] uri uri of a service to connect to, must contain theplatform.
        #
        # @return [Excon] assembled excon objects with service defaults.
        # @return [Excon[]] if nil, an array of all open connections.
        #
        def [](uri = nil)
          return @open_connections unless uri
          begin
            parsed_uri = URI.parse uri
          rescue URI::InvalidURIError
            raise ArgumentError, "#{uri} is not a uri"
          end

          raise ArgumentError, "#{uri} does not contain theplatform in it." unless parsed_uri.host.include? "theplatform"

          Excon.new([parsed_uri.scheme, parsed_uri.host].join("://"), persistent: true) unless @open_connections.include? parsed_uri.host
        end

        Excon.defaults[:headers] = {
          'Content-Type'     => "application/json",
          "User-Agent"       => "cts-mpx ruby sdk version #{Cts::Mpx::VERSION}",
          'Content-Encoding' => 'bzip2,xz,gzip,deflate'
        }
        @open_connections = []
      end
    end
  end
end
