RSpec::Matchers.define :raise_error_without_required_keyword do |keyword|
  match do
    begin
      actual.call
    rescue ArgumentError => e
      return e.message.match?(/#{keyword} is a required keyword./)
    end
    false
  end

  def supports_block_expectations?
    true
  end

  description do
    "raise an ArgumentError with: '#{keyword} is a required keyword'"
  end

  failure_message do
    "#{actual.source} did not raise an ArgumentException with: #{keyword} is a required keyword."
  end
end

RSpec::Matchers.define :raise_error_without_user_token do
  match do
    token = user.token
    user.instance_variable_set :@token, nil
    begin
      actual.call
    rescue RuntimeError => e
      user.token = token
      return e.message.match?(/#{user.username} is not signed in, \(token is set to nil\)\./)
    end
    user.token = token
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
