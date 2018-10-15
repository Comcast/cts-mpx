module Cts
  module Mpx
    module Services
      # Collection of procedural methods to interact with the Data services
      # All of these methods mimic the DSS clients as close as possible
      # If your operation does not work in the DSS client, it will not work here
      module Data
        module_function

        # Addressable method, indexed by data service title
        # @param [String] key service title to look up the service object
        # @raise [ArgumentError] if the key is not a service name
        # @raise [ArgumentError] if the key is not a string
        # @return [Service[]] if no key, return the entire array of services
        # @return [Service] a service
        def [](key = nil)
          services = Services[].select { |s| s.type == 'data' }
          return services unless key
          raise ArgumentError, 'key must be a string' unless key.is_a? String
          service = services.find { |e| e.name == key }
          raise ArgumentError, "#{key} must be a service name." unless service
          service
        end

        # Procedural method to DELETE data from the data services
        # @raise (see #get)
        # @param (see #get)
        # @return (see #get)
        def delete(user: nil, account: nil, service: nil, endpoint: nil, sort: nil, extra_path: nil, range: nil, ids: nil, query: {}, headers: {}, count: nil, entries: nil)
          get(user: user, account: account, service: service, endpoint: endpoint, sort: sort, extra_path: extra_path, range: range, ids: ids, query: query, headers: headers, count: count, entries: entries, method: :delete)
        end

        # Procedural method to GET data from the data services
        # @param [Boolean] count ask for a count of objects from the services
        # @param [Boolean] entries return an array of entries
        # @param [User] user user to make calls with
        # @param [Hash] query additional parameters to add to the http call
        # @param [Hash] headers additional headers to attach to the http call
        # @param [String] account context account id or name
        # @param [String] endpoint endpoint to make the call against
        # @param [String] extra_path additional part to add to the path
        # @param [String] fields comma delimited list of fields to collect
        # @param [String] ids comma delimited list of short id's to add to the path
        # @param [String] range string (service) format of a range
        # @param [String] service title of a service
        # @param [String] sort set the sort field
        # @raise (see #prep_call)
        # @return [Response] Response of the call
        def get(user: nil, account: nil, service: nil, fields: nil, endpoint: nil, sort: nil, extra_path: nil, range: nil, ids: nil, query: {}, headers: {}, count: nil, entries: nil, method: :get)
          prep_call(user: user, account: account, service: service, query: query, headers: headers, required_arguments: ['user', 'service', 'endpoint'], binding: binding)

          host = Driver::Assemblers.host user: user, service: service, account_id: account
          path = Driver::Assemblers.path service: service, endpoint: endpoint, extra_path: extra_path, ids: ids
          query = Driver::Assemblers.query user: user, account: account, service: service, endpoint: endpoint, query: query

          if Services[service].type == 'data'
            query.merge! Driver::Assemblers.query_data range: range, count: count, entries: entries, sort: sort
            query[:fields] = fields if fields
          end
          request = Driver::Request.create(method: method, url: [host, path].join, query: query, headers: headers)
          request.call
        end

        # Procedural method to POST data to the data services
        # @param [Driver::Page] page formated page to send to the data services
        # @param [User] user user to make calls with
        # @param [Hash] query additional parameters to add to the http call
        # @param [Query] headers additional headers to attach to the http call
        # @param [String] account account context, can be id or name
        # @param [String] endpoint endpoint to make the call against
        # @param [String] extra_path additional part to add to the path
        # @param [String] service title of a service
        # @raise (see #prep_call)
        # @return [Response] Response of the call
        def post(user: nil, account: nil, service: nil, endpoint: nil, extra_path: nil, query: {}, page: nil, headers: {}, method: :post)
          prep_call(user: user, account: account, service: service, query: query, headers: headers, required_arguments: ['user', 'service', 'endpoint', 'page'], page: page, binding: binding)

          host = Driver::Assemblers.host user: user, service: service
          path = Driver::Assemblers.path service: service, endpoint: endpoint, extra_path: extra_path
          query = Driver::Assemblers.query user: user, account: account, service: service, endpoint: endpoint, query: query

          request = Driver::Request.create(method: method, url: [host, path].join, query: query, headers: headers, payload: page.to_s)
          request.call
        end

        # Procedural method to PUT data to the data services
        # @param (see #post)
        # @raise (see #post)
        # @return (see #post)
        def put(user: nil, account: nil, service: nil, endpoint: nil, extra_path: nil, query: {}, page: nil, headers: {})
          post(user: user, account: account, service: service, endpoint: endpoint, extra_path: extra_path, query: query, page: page, headers: headers, method: :put)
        end

        # Helper method to assure that everything is is ok to call the methods above
        # @param [Hash] args params to assure are correct
        # @option args [Symbol] :account account to apply to account_context lookups
        # @option args [Symbol] :binding local binding (goes with required arguments)
        # @option args [Symbol] :headers header object to check
        # @option args [Symbol] :page page to send to the data service
        # @option args [Symbol] :query query object to test
        # @option args [Symbol] :required_arguments list of arguments required
        # @option args [Symbol] :service title of the service
        # @option args [Symbol] :user user to make calls with
        # @raise [ArgumentError] if :query or :headers values are not a Hash
        # @raise [ArgumentError] if the :page value is not a Page
        # @raise [ArgumentError] if the list of :required_arguments are not set
        # @raise [ArgumentError] if the :user does not have a token
        # @raise (see Registry#fetch_domain)
        # @raise (see Registry#store_domain)
        # @return [Response] Response of the call
        # @private
        def prep_call(args = {})
          Driver::Helpers.required_arguments args[:required_arguments], args[:binding]
          Driver::Helpers.raise_if_not_a([args[:user]], User) if args[:user]
          Driver::Helpers.raise_if_not_a_hash [args[:query], args[:headers]]
          Driver::Helpers.raise_if_not_a([args[:page]], Driver::Page) if args[:page]
          args[:user].token!
          Registry.fetch_and_store_domain(args[:user], args[:account])
        end
      end
    end
  end
end
