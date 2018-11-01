require 'spec_helper'

module Cts
  module Mpx
    describe Fields do
      let(:data) do
        {
          id:       id,
          service:  service,
          endpoint: endpoint
        }
      end

      let(:endpoint) { 'Media' }
      let(:id) { 'http://data.media.theplatform.com/media/data/Media/1' }
      let(:service) { 'Media Data Service' }

      let(:fields) { described_class.new }
      let(:id_field) { Field.create name: 'id', value: 'value' }
      let(:guid_field) { Field.create name: 'guid', value: 'value' }
      let(:custom_field) { Field.create name: '$uuid', xmlns: { 'custom' => 'uuid' } }
      let(:xmlns) { { "custom" => 'namespace://' } }
      let(:loadable_hash) do
        {
          xmlns: xmlns,
          entry: data
        }
      end

      it { is_expected.to be_a_kind_of Enumerable }
      it { is_expected.to be_a_kind_of Creatable }

      describe "Attributes" do
        it { is_expected.to have_attributes(collection: []) }
      end

      describe "Class methods" do
        it { expect(described_class).to respond_to(:create) }
        it { expect(described_class).to respond_to(:create_from_data).with_keywords :data, :xmlns }
      end

      describe "Instance methods" do
        it { is_expected.to respond_to(:[]).with(0..1).arguments }
        it { is_expected.to respond_to(:[]=).with(2).arguments.and_keywords(:xmlns) }
        it { is_expected.to respond_to(:add).with(1).argument }
        it { is_expected.to respond_to(:each) }
        it { is_expected.to respond_to(:parse).with_keywords :xmlns, :data }
        it { is_expected.to respond_to(:remove).with(1).argument }
        it { is_expected.to respond_to(:reset).with(0).arguments }
        it { is_expected.to respond_to(:to_h).with(0).arguments }
        it { is_expected.to respond_to(:to_s).with(0).arguments }
        it { is_expected.to respond_to(:xmlns).with(0).arguments }
      end

      describe '::self.create_from_data' do
        let(:data) { {} }
        let(:xmlns) { {} }
        let(:new_obj) { described_class.new }

        it "is expected to call new with no arguments" do
          allow(described_class).to receive(:new).and_call_original
          described_class.create_from_data data: data, xmlns: xmlns
          expect(described_class).to have_received(:new).with(no_args)
        end

        it "is expected to call parse with xmlns and data" do
          allow(described_class).to receive(:new).and_return(new_obj)
          allow(new_obj).to receive(:parse).and_call_original
          described_class.create_from_data data: {}, xmlns: {}
          expect(new_obj).to have_received(:parse)
        end
      end

      describe '::[] (addressable method)' do
        context "when no result could be found" do
          it "is expected to return nil" do
            expect(fields['not_there']).to eq nil
          end
        end

        it "is expected to index by custom field name" do
          fields.add custom_field
          expect(fields['custom$uuid']).to eq custom_field.value
        end

        it "is expected to index by field name" do
          fields.add id_field
          expect(fields['id']).to eq id_field.value
        end

        it "is expected to return the value of the field." do
          fields.add guid_field
          expect(fields['guid']).to eq guid_field.value
        end
      end

      describe "::[]=" do
        context "when the field already exists" do
          before do
            fields.add id_field
            fields.add guid_field
          end

          it "is expected to set the original field to the new value" do
            expect { fields['id'] = 'new_value' }.to change { fields['id'] }.to 'new_value'
          end
        end

        it "is expected to call Field.create with key/value and xmlns" do
          allow(Field).to receive(:create).and_call_original
          fields.[]= 'id', 'value', xmlns: xmlns
          expect(Field).to have_received(:create).with(name: 'id', value: 'value', xmlns: xmlns)
        end

        it "is expected to add them to @collection" do
          expect { fields.[]= 'id', 'value', xmlns: xmlns }.to change(fields, :collection).to array_including kind_of Field
        end
      end

      describe '::add' do
        context "when the provided field is not a kind of Field" do
          it { expect { fields.add(1) }.to raise_argument_error(1, Field) }
        end

        context 'when the provided field is already in @collections' do
          before { fields.add id_field }

          it { expect { fields.add id_field }.not_to change(fields, :collection) }
        end

        it "is expected to add the argument to @collection" do
          expect { fields.add id_field }.to change(fields, :collection).to([id_field])
        end

        it "is expected to return self" do
          expect(fields.add(id_field)).to eq fields
        end
      end

      describe '::each' do
        before do
          fields.add id_field
          fields.add guid_field
        end

        specify { expect { |b| fields.each(&b) }.to yield_control.twice }
      end

      describe '::parse' do
        context "when data is not a hash" do
          it { expect { fields.parse data: 1 }.to raise_argument_error(1, Hash) }
        end

        context "when xmlns is provided" do
          it "is expected to pass xmlns to create" do
            allow(Field).to receive(:create)
            fields.parse data: data, xmlns: xmlns
            expect(Field).to have_received(:create).with a_hash_including(xmlns: xmlns)
          end
        end

        ['service', 'endpoint'].each do |verb|
          it "is expected to ignore the key #{verb}" do
            allow(Field).to receive(:create)
            fields.parse data: data
            expect(Field).to have_received(:create).with hash_excluding(verb => verb)
          end
        end

        it "is expected to call reset" do
          allow(fields).to receive(:reset)
          fields.parse data: data
          expect(fields).to have_received(:reset)
        end

        it "is expected create a new field object for each key/value pair" do
          allow(Field).to receive(:create)
          fields.parse data: data
          expect(Field).to have_received(:create).with(hash_including(name: 'id', value: id))
        end
      end

      describe '::reset' do
        it 'is expected to empty the collection' do
          fields.add id_field
          expect { fields.reset }.to change(fields, :collection).to([])
        end
      end

      describe '::remove' do
        context "when the provided field is not a kind of Field" do
          it { expect { fields.add(1) }.to raise_argument_error(1, Field) }
        end

        it "is expected to remove the argument from @collection" do
          fields.add id_field
          expect { fields.remove id_field.name }.to change(fields, :collection).to([])
        end
      end

      describe '::to_h' do
        before { fields.add id_field }

        it "is expected to return a hash with all fields as name:value pairs" do
          expect(fields.to_h).to eq('id' => 'value')
        end
      end

      describe 'xmlns' do
        before do
          fields.add id_field
          fields.add custom_field
        end

        it "is expected to return a composite of all fields with xmlns set" do
          expect(fields.xmlns).to eq("custom"=>"uuid")
        end
      end
    end
  end
end
