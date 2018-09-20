require 'spec_helper'

module Cts
  module Mpx
    module Driver
      describe Helpers do
        it { expect(described_class.class).to be Module }

        describe "Module method signatures" do
          it { expect(described_class).to respond_to(:raise_if_not_a).with(2).arguments }
          it { expect(described_class).to respond_to(:raise_if_not_a_hash).with(1).arguments }
          it { expect(described_class).to respond_to(:raise_if_not_an_array).with(1).arguments }
          it { expect(described_class).to respond_to(:required_arguments).with(2).arguments }
        end

        describe '::raise_if_not_a' do
          let(:args) { [['1'], String] }

          it 'is expected to call Driver::Exceptions.raise_unless_argument_error against each object' do
            allow(Driver::Exceptions).to receive(:raise_unless_argument_error?)
            described_class.raise_if_not_a(*args)
            expect(Driver::Exceptions).to have_received(:raise_unless_argument_error?).with("1", String)
          end

          it { expect(described_class.raise_if_not_a(*args)).to eq nil }
        end

        describe '::raise_if_not_an_array' do
          let(:args) { [[1, 2, 3]] }

          it 'is expected to call raise_if_not_a_hash against each object' do
            allow(described_class).to receive(:raise_if_not_a)
            described_class.raise_if_not_an_array(*args)
            expect(described_class).to have_received(:raise_if_not_a).with(args.first, Array)
          end

          it { expect(described_class.raise_if_not_an_array(args)).to eq nil }
        end

        describe '::raise_if_not_a_hash' do
          let(:args) { [{ one: 'one' }] }

          it 'is expected to call raise_if_not_a_hash against each object' do
            allow(described_class).to receive(:raise_if_not_a)
            described_class.raise_if_not_a_hash(*args)
            expect(described_class).to have_received(:raise_if_not_a).with(args.first, Hash)
          end

          it { expect(described_class.raise_if_not_a_hash(args)).to eq nil }
        end

        describe '::required_arguments' do
          it 'is expected to call Driver::Exceptions.raise_unless_argument_error against each object' do
            b = binding.dup
            b.local_variable_set(:arg, 'arrrrgh')
            allow(Driver::Exceptions).to receive(:raise_unless_required_keyword?)
            described_class.required_arguments([:arg], b)
            expect(Driver::Exceptions).to have_received(:raise_unless_required_keyword?)
          end

          it do
            b = binding
            b.local_variable_set(:arg, 'arrrrgh')
            expect(described_class.required_arguments([:arg], b)).to eq nil
          end
        end
      end
    end
  end
end
