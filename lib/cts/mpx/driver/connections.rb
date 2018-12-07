module Cts
  module Mpx
    module Driver
      # Container for active connections to the data service.
      module Connections
        module_function

        # Addressable method for active connections.   If you provide a string that is not active, an active one
        # will be created.
        # @param [String] uri uri of a service to connect to, must contain theplatform.
        # @return [Excon] assembled excon objects with service defaults.
        # @return [Excon[]] if nil, an array of all open connections.
        def [](uri = nil)
          return @collection unless uri

          begin
            parsed_uri = URI.parse uri
          rescue URI::InvalidURIError
            raise ArgumentError, "(#{uri}) is not a uri"
          end

          raise ArgumentError, "(#{uri}) does not contain theplatform in it." unless parsed_uri.host&.include? "theplatform"

          c = create_connection parsed_uri unless @collection.include? parsed_uri.host
          @collection.push c
          @collection.last
          c
        end

        def create_connection(parsed_uri)
          Excon.new([parsed_uri.scheme, parsed_uri.host].join("://"), persistent: true)
        end

        def collection
          @collection
        end

        def initialize
          Excon.defaults[:omit_nil] = true
          Excon.defaults[:persistent] = true
          Excon.defaults[:headers] = {
            'Content-Type'     => "application/json",
            "User-Agent"       => "cts-mpx ruby sdk version #{Cts::Mpx::VERSION}",
            'Content-Encoding' => 'bzip2,xz,gzip,deflate'
          }

          @collection = []
        end
      end
    end
  end
end
