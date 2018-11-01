module Cts
  module Mpx
    # Enumerable collection that can store an entry in it
    # @attribute collection storage for the individual entry
    #   @return [Entry[]]
    class Entries
      include Enumerable
      include Driver
      include Creatable
      extend Forwardable

      attribute name: 'collection', kind_of: Array

      # Create a new entries collection from a page
      # @param [Page] page the page object to process
      # @raise [ArgumentError] if :page is not available
      # @return [Entries] a new entries collection
      def self.create_from_page(page)
        Exceptions.raise_unless_argument_error? page, Page
        entries = page.entries.each do |e|
          entry = Entry.create(fields:  Fields.create_from_data(data: e, xmlns: page.xmlns))
          entry.id = entry.fields['id'] if entry.fields['id']
        end
        Entries.create(collection: entries)
      end

      # Addressable method, indexed by entry object
      # @param [Entry] key the entry to return
      # @return [Self.collection,Entry,nil] Can return the collection, a single entry, or nil if nothing found
      def [](key = nil)
        return @collection unless key

        @collection.find { |e| e.id == key }
      end

      def +(other)
        Entries.create collection: @collection += other.collection
      end

      def -(other)
        Entries.create collection: @collection += other.collection
      end

      # Add an entry object to the collection
      # @param [Entry] entry instantiated Entry to include
      # @raise [ArgumentError] if entry is not an Entry
      # @return [Self]
      def add(entry)
        return self if @collection.include? entry

        Exceptions.raise_unless_argument_error? entry, Entry
        @collection.push entry
        self
      end

      # Iterator method for self
      # @return [Entry] next object in the list
      def each
        @collection.each { |c| yield c }
      end

      # Reset the entry array to a blank state
      # @return [Void]
      def initialize
        reset
      end

      # Remove a entry object from the collection
      # @param [Entry] argument instantiated Entry to remove
      # @return [Self]
      def remove(argument)
        @collection.delete_if { |f| f == argument }
      end

      # Reset the entry array to a blank state
      # @return [Void]
      def reset
        @collection = []
      end

      # A hash of all available entries
      # @return [Hash]
      def to_h
        map(&:to_h)
      end
    end
  end
end
