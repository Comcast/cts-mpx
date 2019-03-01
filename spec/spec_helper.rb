$LOAD_PATH.unshift File.expand_path('../lib', __dir__)
require 'simplecov'
require 'simplecov-console'
require 'pry'
require 'excon'

require 'spec_helper_parameters'
require 'spec_helper_shared_examples'
require 'spec_helper_shared_contexts'
require 'spec_helper_custom_matchers'

Excon.defaults[:mock] = true # blocks outbound communication.

Dir.glob("spec/matchers/*.rb").each { |f| require(f[5..-1]) }

RSpec.configure do |config|
  config.filter_run :focus
  config.run_all_when_everything_filtered = true
  config.example_status_persistence_file_path = "tmp/examples.txt"
end

RSpec::Matchers.alias_matcher :return_a_kind_of, :be_a_kind_of

RSpec::Core::MemoizedHelpers.define_method(:result_is_expected) do
  expect(subject.yield) # rubocop: disable RSpec/VoidExpect
end

RSpec::Core::MemoizedHelpers.define_method(:result) do
  subject.yield
end

SimpleCov.formatters = [
  SimpleCov::Formatter::HTMLFormatter
]

SimpleCov.start do
  add_filter "/spec/"
end

require 'cts/mpx'
