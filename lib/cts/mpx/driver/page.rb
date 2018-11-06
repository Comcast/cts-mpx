module Cts
  module Mpx
    module Driver
      # <Description>
      # @attribute entries
      #   @return [Array] array of deserialized entries
      # @attribute xmlns
      #   @return [Hash] active namespace received for this page
      class Page
        include Creatable
        include Enumerable

        attribute name: 'entries', kind_of: Array
        attribute name: 'xmlns', kind_of: Hash

        def initialize
          @entries = []
          @xmlns = {}
        end

        def to_mpx_entries
          c = @entries.map do |e|
            new_entry = Entry.create(fields: Fields.create_from_data(data: e, xmlns: xmlns))
            new_entry.id = new_entry.fields['id']
            new_entry
          end

          e = Entries.create collection: c
          e
        end

        # return a json copy of the object, useful for later interpreation
        # @param [Object] indent_depth sets indent depth to 2 if not nil
        # @return [String] json serialized copy of the page
        def to_s(indent_depth = nil)
          indent_depth = 2 if indent_depth

          Oj.dump(
            {
              "xmlns"   => xmlns,
              "entries" => entries
            },
            indent: indent_depth
          )
        end
      end
    end
  end
end
