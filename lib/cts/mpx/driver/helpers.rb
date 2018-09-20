module Cts
  module Mpx
    module Driver
      #
      # Collection of simple helpers for the development of the SDK
      #
      module Helpers
        module_function

        #
        # used to raise an exception if the array of objects is not of the specified type.
        #
        # @param [Object[]] objects array of objects to itterate through
        # @param [Class] type class to check the object array against.
        #
        # @raise [ArgumentError] if the argument is not of the specified type
        #
        # @return [nil] nil
        #
        def raise_if_not_a(objects, type)
          objects.each { |k| Exceptions.raise_unless_argument_error?(k, type) }
          nil
        end

        #
        # Raise an error if any object in the array is not of a type Array
        #
        # @param [Object[]] objects array of objects to test if a valid array
        #
        # @raise [ArgumentError] if the argument is not an [Array]
        # @return [nil] nil
        #
        def raise_if_not_an_array(objects)
          raise_if_not_a(objects, Array)
          nil
        end

        #
        # Raise an error if any object in the array is not of a type Hash
        #
        # @param [Object[]] objects array of objects to test if a valid hash
        #
        # @raise [ArgumentError] if the argument is not a [Hash]
        # @return [nil] nil
        #
        def raise_if_not_a_hash(objects)
          raise_if_not_a(objects, Hash)
          nil
        end

        #
        # Raise an error if any keywords are not included inside of a specified binding.
        #
        # @param [Object] keywords list of keywords to check.
        # @param [Binding] a_binding binding to check for local variables
        #
        # @raise [ArgumentError] if the argument is not of the specified type.
        # @return [nil] nil
        #
        def required_arguments(keywords, a_binding)
          keywords.each { |arg| Exceptions.raise_unless_required_keyword?(keyword: a_binding.local_variable_get(arg)) }
          nil
        end
      end
    end
  end
end
