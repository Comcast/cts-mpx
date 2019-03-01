module Cts
  module Mpx
    module Driver
      # collection of methods used to assemble various parts of a request.
      module Assemblers
        module_function

        # assembles user service and account_id into a host string
        # @param [Cts::Mpx::User] user user to make calls with
        # @param [String] service title of a service
        # @param [String] account_id long form account_id id (ownerId)
        # @raise [ArgumentError] if user or service is not supplied
        # @raise [RuntimeError] if the user token is not set
        # @return [String] assembled scheme and host
        def host(user: nil, service: nil, account_id: 'urn:theplatform:auth:root')
          Helpers.required_arguments %i[user service], binding
          user.token!

          service = Services[service]
          u = URI.parse service.url(account_id)

          [u.scheme, u.host].join('://')
        end

        # Assembles service, endpoint, extra_path, ids, and account_id into a host path
        # @param [String] service title of a service
        # @param [String] endpoint endpoint to make the call against
        # @param [String] extra_path additional part to add to the path
        # @param [String] ids comma delimited list of short id's to add to the path.
        # @param [String] account_id long form account_id id (ownerId)
        # @raise [ArgumentError] if service or endpoint is not supplied
        # @return [String] assembled path for a data call
        def path(service: nil, endpoint: nil, extra_path: nil, ids: nil, account_id: 'urn:theplatform:auth:root')
          Helpers.required_arguments %i[service endpoint], binding
          service_obj = Services[].find { |s| s.name == service && s.endpoints.include?(endpoint) }

          binding.pry unless service_obj
          path = "#{URI.parse(service_obj.url(account_id)).path}/#{service_obj.path}/#{endpoint}"
          path += "/#{extra_path}" if extra_path
          path += "/feed" if service_obj.type == 'data'
          path += "/#{ids}" if ids
          path
        end

        # Assembles service, endpoint, query, range, count, entries, sort and account_id into a query
        # @param [Cts::Mpx::User] user user to make calls with
        # @param [String] account_id long form account_id id (ownerId)
        # @param [String] service title of a service
        # @param [String] endpoint endpoint to make the call against
        # @param [Hash] query any additional parameters to add
        # @param [String] range string (service) format of a range.
        # @param [TrueFalse] count ask for a count of objects from the services.
        # @param [TrueFalse] entries return an array of entries.
        # @param [String] sort set the sort field
        # @raise [ArgumentError] if user, service or endpoint is not supplied
        # @raise [RuntimeError] if the user token is not set
        # @return [Hash] assembled query for a data call
        def query(user: nil, account_id: nil, service: nil, endpoint: nil, query: {}, range: nil, count: nil, entries: nil, sort: nil)
          Helpers.required_arguments %i[user service endpoint], binding
          user.token!

          service = Services[].find { |s| s.name == service && s.endpoints.include?(endpoint) }

          h = {
            schema: service.type == 'data' ? service.schema : service.endpoints[endpoint]['schema'],
            form:   service.form,
            token:  user.token
          }

          h[:account] = account_id if account_id
          h[:count] =   count if count
          h[:entries] = entries if entries
          h[:range] =   range if range
          h[:sort] =    sort if sort
          h.merge! Oj.load(Oj.dump(query), symbol_keys: true) if query.any?
          h
        end
      end
    end
  end
end
