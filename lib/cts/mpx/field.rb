module Cts
  module Mpx
    # Indivudal field, contains the name, value, and an optional namespace
    # @attribute name name of the field
    #   @return [String]
    # @attribute value value of the field
    #   @return [Object]
    # @attribute xmlns namespace of the field
    #   @return [Hash]
    class Field
      include Creatable

      attribute name: 'name', kind_of: String
      attribute name: 'value'
      attribute(name: 'xmlns', kind_of: Hash) { |o, xmlns| o.xmlns = xmlns if o.custom? }

      # Return just the name value as key/value
      # @return [Hash]
      def to_h
        { name => value }
      end

      # Determines if this field is a custom field or not
      # @return [Symbol] true if it is a custom field
      def custom?
        return true if name.include? "$"

        false
      end

      # Set the namespace of the field
      # @param [Hash] xmlns namespace of the fields
      # @return [Void]
      def xmlns=(xmlns)
        @xmlns = xmlns if name.include? '$'
      end
    end
  end
end
