module Cts
  module Mpx
    # Enumerable collection that can store an entry field in it
    # @attribute collection storage for the individual field
    #   @return [Field[]]
    class Fields
      include Enumerable
      extend Creatable

      attribute name: 'collection', kind_of: Array

      # Create a new fields collection from a data hash
      # @param [Hash] data raw fields to add
      # @param [Hash] xmlns namespace of the fields
      # @raise [ArgumentError] if :data or :xmlns are not provided
      # @return [Fields] a new fields collection
      def self.create_from_data(data: nil, xmlns: nil)
        Driver::Helpers.required_arguments([:data], binding)
        obj = new
        obj.parse(data: data, xmlns: xmlns)
        obj
      end

      # Addressable method, indexed by field name
      # @param [String] key name of the field
      # @return [Self.collection,Field,nil] Can return the collection, a single field, or nil if nothing found
      def [](key = nil)
        return @collection unless key
        result = @collection.find { |f| f.name == key }
        return result.value if result
        nil
      end

      # Addresable set method, indexed by field name
      # @note will create a new copy if it is not found in the collection
      # @param [String] key name of the field
      # @param [Object] value value of the field
      # @param [Hash] xmlns namespace of the field
      # @example to include xmlns, you need to use the long format of this method
      #    fields.[]= 'id', 'value', xmlns: {}
      # @return [Void]
      def []=(key, value, xmlns: nil)
        existing_field = find { |f| f.name == key }
        if existing_field
          existing_field.value = value
        else
          add Field.create name: key, value: value, xmlns: xmlns
        end
      end

      # Add a field object to the collection
      # @param [Field] field instantiated Field to include
      # @raise [ArgumentError] if field is not a Field
      # @return [Self]
      def add(field)
        return self if @collection.include? field
        Driver::Exceptions.raise_unless_argument_error? field, Field
        @collection.push field
        self
      end

      # Iterator method for self
      # @return [Field] next object in the list
      def each
        @collection.each { |c| yield c }
      end

      # Reset the field array to a blank state
      # @return [Void]
      def initialize
        reset
      end

      # Parse two hashes into a field array
      # @note this will also set the collection
      # @param [Hash] xmlns namespace
      # @param [Hash] data fields in hash form
      # @raise [ArgumentError] if xmlns is not a Hash
      # @return [Field[]] returns a collection of fields
      def parse(xmlns: nil, data: nil)
        Driver::Exceptions.raise_unless_argument_error? data, Hash
        data.delete :service
        data.delete :endpoint
        reset
        @collection = data.map { |k, v| Field.create name: k.to_s, value: v, xmlns: xmlns }
      end

      # Remove a field object from the collection
      # @param [String] name instantiated Field to remove
      # @return [Self]
      def remove(name)
        @collection.delete_if { |f| f.name == name }
      end

      # Reset the field array to a blank state
      # @return [Void]
      def reset
        @collection = []
      end

      # return the fields as a hash
      # @return [Hash] key is name, value is value
      def to_h
        h = {}
        each { |f| h.store f.name, f.value }
        h
      end

      # Return the cumulative namespace of all Field's in the collection
      # @return [Hash] key is the namespace key, value is the value
      def xmlns
        a = collection.map(&:xmlns).uniq
        a.delete nil
        h = {}
        a.each { |e| h.merge! e }
        h
      end
    end
  end
end
