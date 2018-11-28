require 'spec_helper'

module Cts
  module Mpx
    describe Field do
      include_context "with field objects"

      it { is_expected.to be_a_kind_of Creatable }
      it { is_expected.to have_attributes(name: nil) }
      it { is_expected.to have_attributes(value: nil) }
      it { is_expected.to have_attributes(xmlns: nil) }
      it { is_expected.to respond_to(:name).with(0).argument }
      it { is_expected.to respond_to(:to_h).with(0).argument }
      it { is_expected.to respond_to(:type).with(0).argument }

      describe '::to_h' do
        it "is expected to have a key set to name" do
          expect(field.name).to eq field_name
        end

        it "is expected to have a value set to value" do
          expect(field.value).to eq field_value
        end
      end

      describe '::type' do
        context "when xmlns is not nil" do
          it { expect(custom_field.type).to eq :custom }
        end

        it { expect(field.type).to eq :internal }
      end
    end
  end
end
