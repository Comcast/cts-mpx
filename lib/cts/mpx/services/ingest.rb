module Cts
  module Mpx
    module Services
      # Collection of methods to interact with the ingest services
      module Ingest
        module_function

        # Addressable method, indexed by ingest service title
        # @param [String] key ingest service title to look up the service object
        # @raise [ArgumentError] if the key is not a service name
        # @raise [ArgumentError] if the key is not a string
        # @return [Service[]] if no key, return the entire array of services
        # @return [Service] a service
        def [](key = nil)
          return services unless key
          Driver::Exceptions.raise_unless_argument_error?(key, String)

          service = services.find { |e| e.name == key }
          Driver::Exceptions.raise_unless_argument_error?(service, Driver::Service)

          service
        end

        # Ingest service list
        # @return [Services[]] Array of ingest services
        def services
          Services[].select { |s| s.type == 'ingest' }
        end

        # Procedural method to interact with an ingest service via POST
        # @param [User] user user to make calls with
        # @param [Hash] headers additional headers to attach to the http call
        # @param [String] account account context, can be id or name
        # @param [String] endpoint endpoint to make the call against
        # @param [String] extra_path additional part to add to the path
        # @param [String] payload string to send to ingest
        # @param [String] service title of a service
        # @raise [ArgumentError] if headers is not a [Hash]
        # @raise [ArgumentError] if the list of [User], service or endpoint is not included
        # @raise [ArgumentError] if the [User] does not have a token
        # @raise (see Registry#fetch_domain)
        # @raise (see Registry#store_domain)
        # @return [Response] Response of the call
        def post(user: nil, account: nil, service: nil, endpoint: nil, headers: {}, payload: nil, extra_path: nil)
          Driver::Helpers.required_arguments ['user', 'service', 'endpoint'], binding
          Driver::Helpers.raise_if_not_a_hash [headers]
          user.token!

          Registry.fetch_and_store_domain(user, account) unless self[service].url?

          host = Driver::Assemblers.host user: user, service: service
          path = Driver::Assemblers.path service: service, endpoint: endpoint, extra_path: extra_path

          request = Driver::Request.create(method: :post, url: [host, path].join, payload: payload, headers: headers)
          request.call
        end
      end
    end
  end
end
