module Cts
  module Mpx
    # ORM style class to contain any entry from the data services.
    class Entry
      include Creatable

      attribute name: 'endpoint', kind_of: String
      attribute name: 'fields', kind_of: Fields
      attribute name: 'id', kind_of: String
      attribute name: 'service', kind_of: String

      # Load a Entry based on a long form ID
      # @param [User] user user to make calls with
      # @param [String] id long form id to look up
      # @param [String] fields comma delimited list of fields to collect
      # @return [Entry] the resulting entry
      def self.load_by_id(user: nil, id: nil, fields: nil, account_id: nil)
        Driver::Helpers.required_arguments %i[user id], binding

        Driver::Exceptions.raise_unless_argument_error? user, User
        Driver::Exceptions.raise_unless_reference? id

        e = new
        e.id = id
        e.load user: user, fields: fields, account_id: account_id
        e
      end

      # Return the id of the entry.
      # @return [Entry] the resulting entry
      def id
        fields['id']
      end

      # Set the id of the entry, will check if it's a valid reference.
      # @param [String] account_id account_id to set the entry to
      # @return [Entry] the resulting entry
      def id=(id)
        if id == nil
          fields.remove 'id'
          @id, @service, @endpoint = nil
        else
          Driver::Exceptions.raise_unless_reference? id
          result = Services.from_url id
          fields['id'] = id
          @service = result[:service]
          @endpoint = result[:endpoint]
        end
      end

      # Initialize an entry.
      # Currently only instantiates fields.
      def initialize
        @fields = Fields.new
      end

      # Return a [Hash] of the entry.
      # @return [Hash] includes keys xmlns: [Hash] and entries: [Fields]
      def to_h
        {
          xmlns: fields.xmlns,
          entry: fields.to_h
        }
      end

      # Load data from the remote services based on the id.
      # @param [User] user user to make calls with
      # @param [String] fields comma delimited list of fields to collect
      # @return [Driver::Response] Response of the call.
      def load(user: nil, fields: nil, account_id: nil)
        Driver::Helpers.required_arguments %i[user], binding

        Driver::Exceptions.raise_unless_argument_error? user, User
        Driver::Exceptions.raise_unless_argument_error? fields, String if fields
        Driver::Exceptions.raise_unless_reference? id

        Registry.fetch_and_store_domain user: user, account_id: account_id
        response = Services::Data.get account: account_id, user: user, service: service, endpoint: endpoint, fields: fields, ids: id.split("/").last

        raise RuntimeError, 'could not load ' + id unless response.data['entries'].count.positive?

        self.fields.parse data: response.data['entries'].first, xmlns: response.data['xmlns']
        self
      end

      # Save the entry to the remote services.
      # @param [User] user user to make calls with
      # @return [Driver::Response] Response of the call.
      def save(user: nil)
        Driver::Helpers.required_arguments %i[user], binding
        Driver::Exceptions.raise_unless_argument_error? user, User

        p = Driver::Page.create entries: [fields.to_h], xmlns: fields.xmlns

        if id
          response = Services::Data.put user: user, service: service, endpoint: endpoint, page: p
        else
          raise ArgumentError, "service is a required keyword" unless service
          raise ArgumentError, "endpoint is a required keyword" unless endpoint

          response = Services::Data.post user: user, service: service, endpoint: endpoint, page: p
        end

        response
      end
    end
  end
end
