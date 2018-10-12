module Cts
  module Mpx
    module Driver
      #
      # A single request of any type to the services.
      #
      # @attribute method
      #   @return [Symbol] type of rest method, GET, PUT, POST, DELETE
      # @attribute url
      #   @return [String] url to make the request against
      # @attribute query
      #   @return [Hash] query to send with the request
      # @attribute payload
      #   @return [String] payload to be sent to the services
      # @attribute response
      #   @return [Cts::Mpx::Driver::Response] response from the service
      # @attribute headers
      #   @return [Hash] headers to transmit to the services along with the request
      class Request
        include Creatable

        attribute name: 'method', kind_of: Symbol
        attribute name: 'url', kind_of: String
        attribute name: 'query', kind_of: Hash
        attribute name: 'payload', kind_of: String
        attribute name: 'response', kind_of: ::Cts::Mpx::Driver::Response
        attribute name: 'headers', kind_of: Hash

        # Call the built request.
        # @raise [RuntimeException] if the method is not a get, put, post or delete
        # @raise [RuntimeException] if the url is not a valid reference
        # @return [Cts::Mpx::Driver::Response] response from the service
        def call
          @headers ||= {}
          @query ||= {}

          call_exceptions method, url
          socket = Connections[url]
          params = {
            headers: @headers,
            path:    URI.parse(url).path,
            query:   @query
          }
          params[:body] = payload if payload

          r = socket.send method, params
          @response = Response.create original: r
          @response
        end

        private

        def call_exceptions(method, url)
          raise "#{method} is not a valid method" unless %i[get put post delete].include? method.downcase
          raise "#{url} is not a valid reference" unless Cts::Mpx::Validators.reference? url
        end
      end
    end
  end
end
