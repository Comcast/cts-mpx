module Cts
  module Mpx
    module Driver
      # Class to wrap a service and what is available to interact with
      # @attribute name
      #   @return [String] Title of the service, must be identical to the registry entry
      # @attribute uri_hint
      #   @return [String] partial string of the uri, this allows for a reverse lookup from url
      # @attribute path
      #   @return [String] prepended path statement attached per service
      # @attribute form
      #   @return [String] type of http schema to use, can be json or cjson
      # @attribute schema
      #   @return [String] version of the service schema
      # @attribute search_schema
      #   @return [String] version of the search schema
      # @attribute read_only
      #   @return [Boolean] is this a read only service or not
      # @attribute endpoints
      #   @return [Array] Available endpoints to communicate with
      # @attribute type
      #   @return [String] the type of service this is
      class Service
        attr_accessor :name
        attr_accessor :uri_hint
        attr_accessor :path
        attr_accessor :form
        attr_accessor :schema
        attr_accessor :search_schema
        attr_accessor :read_only
        attr_accessor :endpoints
        attr_accessor :type

        # Set all values to something
        def initialize
          @name = ""
          @uri_hint = ""
          @path = ""
          @form = ""
          @schema = ""
          @search_schema = ""
          @read_only = false
          @endpoints = []
          @type = nil
          @url = nil
        end

        # Return a given url of a service, will look in the local registry
        # @param [String] account_id long form account id (ownerId)
        # @return [String] the url string or nil if none available
        def url(account_id = 'urn:theplatform:auth:root' )
          account_id ||= 'urn:theplatform:auth:root'
          Exceptions.raise_unless_account_id account_id
          reg = Registry.domains[account_id]
          return reg[name] if reg
          nil
        end

        # checks if we have a given entry in the local registry
        # @param [String] account_id long form account id (ownerId)
        # @return [Boolean] true if it is available, false if it is not
        def url?(account_id = 'urn:theplatform:auth:root')
          Exceptions.raise_unless_account_id account_id
          u = url account_id
          return true if u
          false
        end
      end
    end
  end
end
