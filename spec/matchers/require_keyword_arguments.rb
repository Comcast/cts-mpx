RSpec::Matchers.define :require_keyword_arguments do |method, params|
  match do
    params.each do |_arg|
      dup_params = Oj.load Oj.dump params
      begin
        described_class.send(method, dup_params)
      rescue ArgumentError => e
        return e.message.match?(/is a required keyword./)
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
