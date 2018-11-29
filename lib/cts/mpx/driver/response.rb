module Cts
  module Mpx
    module Driver
      # Class to contain a response from the services, has a few helper methods to make reading the data easier.
      # @!attribute original
      #   @return [Excon::Response] copy of the original excon response.
      class Response
        include Creatable
        attribute name: 'original', kind_of: Excon::Response

        # Hash output of the data returned from the services.
        # @return [Hash] Hash including keys specific to the service and type of service.
        def data
          return @data if @data

          raise 'response does not appear to be healthy' unless healthy?

          # TODO make the driver.load file become load string.
          begin
            @data = Oj.load(original.body)
          rescue Oj::ParseError => e
            raise "could not parse data: #{e}"
          end

          raise ServiceError, "title: #{@data["title"]} description: #{@data["description"]} cid: (#{@data["correlationId"]})" if @data['isException']

          @data
        end

        # Is the response healthy?   did it have a status code outside 2xx or 3xx.
        # @return [TrueFalse] false if status <= 199 or => 400, otherwise true.
        def healthy?
          return false if status <= 199 || status >= 400

          true
        end

        # Does this response contain a service exception
        # @return [TrueFalse] true if it does, false if it does not.
        def service_exception?
          original.body.include? '"isException":true,'
        end

        # a page of data, processes the response.data for any entries.
        # @return [Cts::Mpx::Driver::Page] a page of data.
        def page
          raise 'response does not appear to be healthy' unless healthy?

          Cts::Mpx::Driver::Page.create entries: data['entries'], xmlns: data['$xmlns']
        end

        # Status code of the response
        # @return [Fixnum] http status code
        def status
          original.status || nil
        end
      end
    end
  end
end
