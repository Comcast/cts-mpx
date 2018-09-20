RSpec::Matchers.define :raise_unless_required_argument do |variable, variable_type|
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
    "raise an error if the argument is not a(n) #{variable_type}"
  end

  failure_message do
    "#{variable} did not raise an ArgumentError as expected"
  end
end
