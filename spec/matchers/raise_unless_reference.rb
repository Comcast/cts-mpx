RSpec::Matchers.define :raise_unless_reference do |variable|
  match do
    begin
      actual.call
    rescue ArgumentError => e
      return e.message.match?(/#{variable} is not a valid reference/)
    end
    false
  end

  def supports_block_expectations?
    true
  end

  description do
    "raise an error if the argument is not a reference"
  end

  failure_message do
    "#{variable} did not raise an ArgumentError (reference) as expected"
  end
end
