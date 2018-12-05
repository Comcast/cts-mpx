module Cts
  module Mpx
    # Query method, allows you to build and send a query to the data services.
    # @attribute account
    #   @return [String] account account context, can be id or name
    # @attribute endpoint
    #   @return [String] endpoint of the service
    # @attribute extra_path
    #   @return [String] any extra_path
    # @attribute fields
    #   @return [String] Fields to gather
    # @attribute ids
    #   @return [Array] Ids to search through
    # @attribute page
    #   @return [Page] Page of the search results
    # @attribute query
    #   @return [Hash] Additional query to add
    # @attribute range
    #   @return [String] String range in the service shell style
    # @attribute return_count
    #   @return [Boolean] should this query return count (generally, no)
    # @attribute return_entries
    #   @return [Boolean] should this query return entries
    # @attribute service
    #   @return [String] service the query is for
    # @attribute sort
    #   @return [String] string to sort in the service shell style
    class Query
      include Creatable

      attribute name: 'account_id', kind_of: String
      attribute name: 'endpoint', kind_of: String
      attribute name: 'extra_path', kind_of: String
      attribute name: 'fields', kind_of: String
      attribute name: 'ids', kind_of: Array
      attribute name: 'page', kind_of: Driver::Page
      attribute name: 'query', kind_of: Hash
      attribute name: 'range', kind_of: String
      attribute name: 'return_count'
      attribute name: 'return_entries'
      attribute name: 'service', kind_of: String
      attribute name: 'sort', kind_of: String

      # List of attributes availble
      # @return [Symbol[]]
      def attributes
        %i[account_id endpoint extra_path fields ids query range return_count return_entries service sort]
      end

      # Instiatiate a page and query, set return's to false.
      def initialize
        @page = Driver::Page.new

        @return_entries = true
        @return_count = false
        @query = {}
      end

      # List of entries created from the page
      # @return [Entries] populated Entries object
      def entries
        @page.to_mpx_entries
      end

      # Run the query
      # @param [User] user user to make calls with
      # @return [Self]
      def run(user: nil)
        Driver::Helpers.required_arguments %i[user], binding
        Driver::Exceptions.raise_unless_argument_error? user, User

        raise "service must be set" unless service
        raise "endpoint must be set" unless endpoint

        response = Services::Data.get params.merge(user: user)
        @page = response.page
        self
      end

      # Hash representation of the query data.  Has a key for params and for entries.
      # @param [Boolean] include_entries include the entries array or not
      # @return [Hash]
      def to_h(include_entries: true)
        h = { params: params }
        h[:entries] = entries.to_h if include_entries
        h
      end

      private

      # List of parameters that are currently set in the query
      # @return [Hash]
      def params
        output = {}

        attributes.each do |attribute|
          output.store attribute, instance_variable_get("@#{attribute}") unless instance_variable_get("@#{attribute}").nil?
        end

        output[:count] = output.delete :return_count unless output[:return_count].nil?
        output[:entries] = output.delete :return_entries unless output[:return_entries].nil?

        output
      end
    end
  end
end
