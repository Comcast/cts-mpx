RSpec::Matchers.define :raise_error_without_user_token do
  match do
    token = user.token
    user.instance_variable_set :@token, nil
    begin
      actual.call
    rescue RuntimeError => e
      user.instance_variable_set :@token, token
      return e.message.match?(/#{user.username} is not signed in, \(token is set to nil\)\./)
    end
    user.instance_variable_set :@token, token
    false
  end

  def supports_block_expectations?
    true
  end

  description do
    "raise an error if the user does not have a token."
  end

  failure_message do
    "#{user} does not have a token set and did not raise an error"
  end
end
