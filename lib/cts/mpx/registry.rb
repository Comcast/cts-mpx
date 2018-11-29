module Cts
  module Mpx
    # Set of procedural functions to interact with the Registry.
    module Registry
      module_function

      # Collection of domains stored in memory
      # @return [Hash] key is an account_id, value is a hash of results
      def domains
        @domains
      end

      # Call fetch and store domain in sequence.
      # @param [User] user user to make calls with
      # @param [String] account_id long form account id (ownerId)
      # @raise (see #fetch_domain)
      # @return [Hash] hash of the newly fetched domain
      def fetch_and_store_domain(user, account_id = 'urn:theplatform:auth:root')
        account_id ||= 'urn:theplatform:auth:root'
        result = fetch_domain user, account_id
        store_domain result, account_id
        domains[account_id]
      end

      # Fetch a domain from the registry.
      # @param [User] user user to make calls with
      # @param [String] account_id long form account id (ownerId)
      # @raise [ArgumentError] if the user is not a user object
      # @raise [ArgumentError] if the account_id is not valid
      # @return [Hash] hash of the newly fetched domain
      def fetch_domain(user, account_id = 'urn:theplatform:auth:root')
        return domains['urn:theplatform:auth:root'] if account_id == 'urn:theplatform:auth:root'

        Driver::Exceptions.raise_unless_argument_error?(user, 'User') { !user.is_a? User }
        user.token!
        Driver::Exceptions.raise_unless_argument_error?(account_id, 'account_id') { !Validators.account_id? account_id }

        response = Services::Web.post user: user, service: 'Access Data Service', endpoint: 'Registry', method: 'resolveDomain', arguments: { 'accountId' => account_id }
        response.data['resolveDomainResponse']
      end

      # Store the domain in memory
      # @param [Hash] data collection received from Registry
      # @param [String] account_id long form account id (ownerId)
      # @raise [ArgumentError] if the data is not a valid hash
      # @raise [ArgumentError] if the account_id is not valid
      # @return [Void]
      def store_domain(data, account_id = 'urn:theplatform:auth:root')
        raise ArgumentError, "#{account_id} is not a valid account_id" unless Validators.account_id? account_id
        raise ArgumentError, "#{data} is not a valid Hash" unless data.is_a? Hash

        @domains.store account_id, data
        nil
      end

      # find and store the root registry from the US
      def initialize
        @domains = {}
        content = File.read "#{Driver.config_dir}/root_registry_sea1.json"
        store_domain(Driver.parse_json(content)['resolveDomainResponse'], 'urn:theplatform:auth:root')
      end
    end
  end
end
