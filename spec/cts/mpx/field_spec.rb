require 'spec_helper'

module Cts
  module Mpx
    describe Field do
      let(:field_name) { 'guid' }
      let(:field_value) { '12345' }
      let(:custom_field_name) { 'custom$guid' }
      let(:guid_field) { described_class.create name: field_name, value: field_value }
      let(:custom_field) { described_class.create(name: custom_field_name, value: 'abcdef', xmlns: { "custom" => "http://1234a.com" }) }

      it { is_expected.to be_a_kind_of Creatable }

      describe "Attributes" do
        it { is_expected.to have_attributes(name: nil) }
        it { is_expected.to have_attributes(value: nil) }
        it { is_expected.to have_attributes(xmlns: nil) }
      end

      describe "Instance methods" do
        it { is_expected.to respond_to(:name).with(0).argument }
        it { is_expected.to respond_to(:to_h).with(0).argument }
        it { is_expected.to respond_to(:type).with(0).argument }

        describe '::to_h' do
          let(:result) { guid_field }

          it "is expected to have a key set to name" do
            expect(result.to_h.keys.first).to eq field_name
          end

          it "is expected to have a value set to value" do
            expect(result.to_h.values.first).to eq field_value
          end
        end

        describe '::type' do
          context "when xmlns is not nil" do
            it "is expected to return :custom" do
              expect(custom_field.type).to eq :custom
            end
          end

          it "is expected to return :internal" do
            expect(guid_field.type).to eq :internal
          end
        end
      end
    end
  end
end
