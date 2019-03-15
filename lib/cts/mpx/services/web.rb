module Cts
  module Mpx
    module Services
      # Collection of procedural methods to interact with the Web services
      # All of these methods mimic the Business clients as close as possible
      # If your operation does not work in the Business client, it will not work here
      module Web
        module_function

        # Addressable method, indexed by web service title
        # @param [String] key service title to look up the service object
        # @raise [ArgumentError] if the key is not a service name
        # @raise [ArgumentError] if the key is not a string
        # @return [Service[]] if no key, return the entire array of services
        # @return [Service] a service
        def [](key = nil)
          return services unless key

          return services.find { |s| s.name = "Access Data Service" } if key == "Access Data Web Service"

          Driver::Exceptions.raise_unless_argument_error?(key, String)
          service = services.find { |e| e.name == key }
          Driver::Exceptions.raise_unless_argument_error?(service, Driver::Service)

          service
        end

        # Web service list
        # @return [Services[]] Array of web services
        def services
          Services[].select { |s| s.type == 'web' }
        end

        # assembles service, endpoint, method, and arguments into a payload
        # @param [String] service title of a service
        # @param [String] endpoint endpoint to make the call against
        # @param [String] method method to make the call against
        # @param [Hash] arguments arguments to send to the method
        # @return [Hash] a hash ready for the web services
        def assemble_payload(service: nil, endpoint: nil, method: nil, arguments: nil)
          Driver::Helpers.required_arguments ['service', 'endpoint', 'method', 'arguments'], binding
          service = Services[service]
          method_list = service.endpoints[endpoint]['methods']
          Driver::Exceptions.raise_unless_argument_error?(arguments, Hash)
          Driver::Exceptions.raise_unless_argument_error?(method, 'method') { !method_list.key?(method) }

          arguments.each_key { |k| Driver::Exceptions.raise_unless_argument_error?(arguments, 'argument') { !method_list[method].include? k.to_s } }

          h = {}
          h[method] = arguments
          h
        end

        # Procedural method to interact with a web service via POST
        # @param [User] user user to make calls with
        # @param [Hash] headers additional headers to attach to the http call
        # @param [Hash] query additional parameters to add to the http call
        # @param [Hash] arguments data to be sent to the data service
        # @param [String] account account context, can be id or name
        # @param [String] method method to make the call against
        # @param [String] endpoint endpoint to make the call against
        # @param [String] extra_path additional part to add to the path
        # @param [String] service title of a service
        # @raise [ArgumentError] if headers is not a [Hash]
        # @raise [ArgumentError] if the list of [User], service or endpoint is not included
        # @raise [ArgumentError] if the [User] does not have a token
        # @raise (see Registry#fetch_domain)
        # @raise (see Registry#store_domain)
        # @return [Response] Response of the call
        def post(user: nil, account: nil, service: nil, endpoint: nil, method: nil, query: {}, headers: {}, arguments: {}, extra_path: nil)
          ### check arguments
          Driver::Helpers.required_arguments ['user', 'service', 'endpoint', 'method', 'arguments'], binding
          Driver::Helpers.raise_if_not_a_hash [query, headers, arguments]
          user.token!

          ### Registry
          Registry.fetch_and_store_domain(user, account) unless self[service].url?

          ### Assemblers/prep
          host = Driver::Assemblers.host user: user, service: service
          path = Driver::Assemblers.path service: service, endpoint: endpoint, extra_path: extra_path
          payload = assemble_payload service: service, endpoint: endpoint, method: method, arguments: arguments
          query = Driver::Assemblers.query user: user, account_id: account, service: service, endpoint: endpoint, query: query

          ### Request
          request = Driver::Request.create(method: :post, url: [host, path].join, query: query, payload: Oj.dump(payload), headers: headers)
          request.call
        end
      end
    end
  end
end
