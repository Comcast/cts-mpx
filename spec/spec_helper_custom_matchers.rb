RSpec::Matchers.define :require_keyword_arguments do |method, params|
  match do
    params.each do |arg|
      dup_params = Oj.load Oj.dump params
      dup_params.delete arg[0]
      begin
        described_class.send(method, dup_params)
      rescue ArgumentError => e
        return e.message.match?(/#{arg} is a required keyword./)
      end
    end
  end

  description do
    "raise an error if a required keyword #{params.keys} is missing."
  end

  failure_message do
    "A required keyword from #{params.keys} failed to raise an ArgumentError with message 'is a required keyword.'"
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
