RSpec::Matchers.define :require_keyword_arguments do |method, params|
  match do
    params.each do |param|
      dup_params = Oj.load Oj.dump params
      dup_params.delete param
      begin
        parent_class.send(method, dup_params)
      rescue ArgumentError => e
        return e.message.match?(/#{param} is a required keyword./)
      end
    end
  end

  description do
    "raise an error if a required keyword from #{params.keys} is missing."
  end

  failure_message do
    "A required keyword from #{params.keys} failed to raise an ArgumentError with message 'is a required keyword.'"
  end
end
