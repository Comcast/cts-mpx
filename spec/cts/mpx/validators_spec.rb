require 'spec_helper'

module Cts
  module Mpx
    describe Validators do
      let(:reference) { account_id }

      describe "::account_id?" do
        it { expect(described_class).to respond_to(:account_id?).with(1).arguments }

        context "when it is not a valid reference" do
          let(:reference) { '1234' }

          it { expect(described_class.reference?(reference)).to eq false }
        end

        context "when it is not an account_id" do
          let(:reference) { "http://media.data.theplatform.com/media/data/Media/1" }

          it { expect(described_class.account_id?(reference)).to eq false }
        end

        it { expect(described_class.account_id?(reference)).to eq true }
      end

      describe "::argument_error?" do
        let(:true_block) { proc { true } }
        let(:false_block) { proc { false } }

        it { expect(described_class).to respond_to(:argument_error?).with(2).arguments }

        context "when a block is supplied" do
          it "is expected to yield to the block" do
            expect { |b| described_class.argument_error?('string', String, &b) }.to yield_with_no_args
          end

          it "is expected to test the return of the block for true" do
            expect(described_class.argument_error?(1234, String, &true_block)).to eq true
          end
        end

        context "when the data does not match the type" do
          it "is expected to return false" do
            expect(described_class.argument_error?(1234, String)).to eq true
          end
        end

        it "is expected to return false" do
          expect(described_class.argument_error?('string', String)).to eq false
        end
      end

      describe "::reference?" do
        let(:reference) { account_id }

        it { expect(described_class).to respond_to(:reference?).with(1).arguments }

        context "when the reference is not a lexically equivalent URI (rfc 3986)" do
          before { reference.gsub!('http', 'htt p') }

          it { expect(described_class.reference?(reference)).to eq false }
        end

        context "when the reference scheme is not http or https" do
          before { reference.gsub!('http', 'ftp') }

          it { expect(described_class.reference?(reference)).to eq false }
        end

        context "when the reference host does not end with .theplatform.com" do
          before { reference.gsub!('theplatform', 'nottheplatform') }

          it { expect(described_class.reference?(reference)).to eq false }
        end

        context "when the reference host is `web.theplatform.com`" do
          it { expect(described_class.reference?('http://web.theplatform.com')).to eq false }
        end

        it { expect(described_class.reference?(reference)).to eq true }
      end
    end
  end
end
