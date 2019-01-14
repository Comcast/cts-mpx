module Cts
  module Mpx
    #
    # Collection of methods that will validate input based on specific tests.
    #
    module Validators
      module_function

      # Validates if a string is a long form id
      # @param [String] account_id long form id
      # @return [Boolean] true if it is a long form id, false if it is not.
      def account_id?(account_id)
        return true if account_id == 'urn:theplatform:auth:root'
        return false unless reference? account_id
        return false unless account_id.downcase.match?(/\/account\/\d+$/)

        true
      end

      # Test to check for validity of argument by type, can also accept a block.
      # @note test
      # @param [Object] data object to check
      # @param [Class] type class type to accept
      # @yield Description of block
      # @yieldreturn [boolean] true if the outcome is valid, false otherwise.
      # @return [boolean] true if the outcome is valid, false otherwise.
      def argument_error?(data, type = nil, &block)
        return block.yield if block
        return true unless type && data.is_a?(type)

        false
      end

      # Validates if a string is a reference
      # @param [String] uri reference
      # @return [Boolean] true if it is a reference, false if it is not.
      def reference?(uri)
        begin
          ref = URI.parse uri
        rescue URI::InvalidURIError
          return false
        end

        return false if ref.host == 'web.theplatform.com'
        return false unless ref.scheme == "http" || ref.scheme == "https"
        return false unless ref.host.end_with? ".theplatform.com"
        return false if ref.host.start_with? 'feed.media.theplatform'

        true
      end
    end
  end
end
