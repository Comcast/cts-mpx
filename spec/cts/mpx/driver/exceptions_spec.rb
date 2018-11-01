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
          it "is expected to raise an ArgumentError if the argument data is not of argument type's type." do
            expect { described_class.raise_unless_argument_error?([], String) }.to raise_error ArgumentError, /\[\] is not a valid String/
          end

          context "when a block is supplied" do
            it "is expected to yield to the block" do
              expect { |b| described_class.raise_unless_argument_error?("this is a string", String, &b) }.to yield_control.once
            end

            it "is expected to test the return of the block" do
              expect { described_class.raise_unless_argument_error?([], String) { false } } .not_to raise_error
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
