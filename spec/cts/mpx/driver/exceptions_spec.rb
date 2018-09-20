require 'spec_helper'

module Cts
  module Mpx
    module Driver
      describe Exceptions do
        let(:false_block) { proc { false } }
        let(:true_block) { proc { true } }

        describe "::raise_unless_account_id" do
          context "when the argument is not an account_id" do
            let(:reference) { 1234 }

            it "is expected to raise a ArgumentError with is not a valid account_id " do
              expect { described_class.raise_unless_account_id(reference) }.to raise_error ArgumentError, /#{reference} is not a valid account_id/
            end
          end

          it "is expected to return nil" do
            expect(described_class.raise_unless_account_id(Parameters.account_id)).to be nil
          end
        end

        describe "::raise_unless_argument_error?" do
          context "when the block is not provided" do
            it "is expected to raise an ArgumentError if data is not of type" do
              expect { described_class.raise_unless_argument_error?([], String) }.to raise_error ArgumentError, /is not a valid String/
            end
          end

          context "when the block returns false" do
            it "is expected to raise a ArgumentError with 'this' is not a valid 'type'" do
              expect { described_class.raise_unless_argument_error?("test", "this", &false_block) }.to raise_error ArgumentError, /test is not a valid this/
            end
          end

          it "is expected to return nil" do
            expect(described_class.raise_unless_argument_error?("test", String)).to be nil
          end
        end

        describe "::raise_unless_reference?" do
          it { expect(described_class).to respond_to(:raise_unless_reference?).with(1).argument }
          context "when the argument is not a reference" do
            let(:reference) { 1234 }

            it "is expected to raise a ArgumentError with is not a valid reference " do
              expect { described_class.raise_unless_reference?(reference) }.to raise_error ArgumentError, /#{reference} is not a valid reference/
            end
          end

          it "is expected to return nil" do
            expect(described_class.raise_unless_reference?(Parameters.account_id)).to be nil
          end
        end

        describe "::raise_unless_required_keyword?" do
          it "is expected to raise an error if required_keyword? returns false" do
            expect { described_class.raise_unless_required_keyword? }.to raise_error ArgumentError, /is a required keyword./
          end
        end
      end
    end
  end
end
