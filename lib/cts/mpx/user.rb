module Cts
  module Mpx
    # Class to wrap the user and basic functions related to it.
    # @attribute username
    #   @return [String] username of the user
    # @attribute password
    #   @return [String] password of the user
    # @attribute idle_timeout
    #   @return [Numeric] how long the token will stay alive without communicating with the services
    # @attribute duration
    #   @return [Numeric] total time to live for the token
    # @attribute token
    #   @return [String] the retrieved token
    class User
      extend Creatable

      attribute name: 'username', type: 'accessor', kind_of: String
      attribute name: 'password', type: 'accessor', kind_of: String
      attribute name: 'idle_timeout', type: 'accessor', kind_of: Integer
      attribute name: 'duration', type: 'accessor', kind_of: Integer
      attribute name: 'token', type: 'accessor', kind_of: String

      # Attempt to sign the user in with the provided credentials
      # @param [Numeric] idle_timeout how long the token will stay alive without communicating with the services
      # @param [Numeric] duration total time to live for the token
      # @return [Self]
      def sign_in(idle_timeout: nil, duration: nil)
        raise 'token is already set, use sign_out first.' if token
        arguments = {}

        arguments['idleTimeout'] if idle_timeout
        arguments['duration'] if duration
        headers = { 'Authorization' => "Basic #{Base64.encode64("#{username}:#{password}").tr "\n", ''}" }

        self.token = 'sign_in_token'
        response = Services::Web.post user: self, service: 'User Data Service', endpoint: 'Authentication', method: 'signIn', arguments: arguments, headers: headers

        raise "sign_in exception, status: #{response.status}" unless response.status == 200
        self.token = response.data['signInResponse']['token']
        self
      end

      # Sign the token out
      # @return [Void]
      def sign_out
        arguments = { "token" => token }
        response = Services::Web.post user: self, service: 'User Data Service', endpoint: 'Authentication', method: 'signOut', arguments: arguments
        self.token = nil if response.status == 200
        nil
      end

      # Override to masq the password
      # @return [String] updated output
      def inspect
        output = "#<#{self.class}:#{(object_id << 1).to_s(16)}"

        %i[username token idle_timeout duration].each do |attribute|
          value = instance_variable_get "@#{attribute}".to_sym
          output += " @#{attribute}=#{value}" unless value.nil?
        end

        output += '>'
        output
      end

      # raise an error if the token is not set, otherwise return the token
      # @return [String] token
      def token!
        raise "#{username} is not signed in, (token is set to nil)." unless token
        token
      end
    end
  end
end
