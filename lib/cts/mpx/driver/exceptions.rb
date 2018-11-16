module Cts
  module Mpx
    module Driver
      module Exceptions
        module_function

        # Raise an ArgumentError if the argument does not pass Validators.account_id?
        # @param [Object] argument argument to test if it is a valid account_id
        # @raise [ArgumentError] if the argument is not a valid account_id
        # @return [nil]
        def raise_unless_account_id(argument)
          raise ArgumentError, "#{argument} is not a valid account_id" unless Validators.account_id? argument

          nil
        end

        # Raise an ArgumentError if the argument is not of the supplied type
        # @param [Object] data argument to test if it is the correct type
        # @param [Object] type type to test for
        # @raise [ArgumentError] if the argument is not of the correct type
        # @return [nil]
        def raise_unless_argument_error?(data, type = nil, &block)
          raise(ArgumentError, "#{data} is not a valid #{type}") if Validators.argument_error?(data, type, &block)

          nil
        end

        # Raise an ArgumentError if the argument does not pass Validators.reference?
        # @param [Object] argument argument to test if it is a valid reference
        # @raise [ArgumentError] if the argument is not a valid reference
        # @return [nil]
        def raise_unless_reference?(argument)
          raise ArgumentError, "#{argument} is not a valid reference" unless Validators.reference? argument

          nil
        end

        # Raise an ArgumentError if the keyword is not supplied.
        # @param [Object] keyword keyword to assure is supplied
        # @raise [ArgumentError] if the keyword is not suppplied
        # @return [nil]
        def raise_unless_required_keyword?(keyword: nil)
          raise ArgumentError, "#{keyword} is a required keyword." unless keyword
        end
      end
    end
  end
end
