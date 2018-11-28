RSpec::Matchers.define :raise_argument_exception do |variable, variable_type|
  match do
    begin
      actual.call
    rescue ArgumentError => e
      return e.message.match?(/#{variable} is not a valid #{variable_type}/)
    end
    false
  end

  def supports_block_expectations?
    true
  end

  description do
    "have raised an error if the argument is not a(n) #{variable_type}"
  end

  failure_message do
    "#{variable} did not raise an ArgumentError as expected"
  end
end

RSpec::Matchers.define :raise_exception_without_required do |keyword|
  match do
    begin
      actual.call
    rescue ArgumentError => e
      return e.message.match?(/#{keyword} is a required/)
    end
    false
  end

  def supports_block_expectations?
    true
  end

  description do
    "have raised an ArgumentError when #{keyword} is not provided."
  end

  failure_message do
    "#{actual.source} did not raise an ArgumentError with: /^#{keyword} is a required/"
  end
end

RSpec::Matchers.define :raise_error_without_user_token do
  match do
    token = user.token
    user.token = nil
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
    "have raised an ArgumentError when the user is not signed in (token is nil)"
  end

  failure_message do
    "#{user} does not have a token set and did not raise an error"
  end
end
