RSpec::Matchers.define :raise_unless_account_id do |variable|
  match do
    begin
      actual.call
    rescue ArgumentError => e
      return e.message.match?(/#{variable} is not a valid account_id/)
    end
    false
  end

  def supports_block_expectations?
    true
  end

  description do
    "raise an error if the argument is not an account_id"
  end

  failure_message do
    "#{variable} did not raise an ArgumentError as expected"
  end
end
