require 'spec_helper'

module Cts
  module Mpx
    describe Entry do
      let(:data) { { id: id } }
      let(:entry) { described_class.create service: service, endpoint: endpoint, id: id, fields: Fields.create(collection: [guid_field, custom_field]) }
      let(:endpoint) { 'Media' }
      let(:new_entry) { described_class.new }
      let(:guid_field) { Field.create name: "guid", value: "abcdef" }
      let(:custom_field) { Field.create name: "$uuid", value: "abcdef", xmlns: { 'custom' => 'uuid' } }
      let(:id) { 'http://data.media.theplatform.com/data/Media/1' }
      let(:loadable_hash) { { xmlns: xmlns, entry: data } }
      let(:service) { 'Media Data Service' }
      let(:body) { Oj.dump page_hash }
      let(:response) { Cts::Mpx::Driver::Response.create original: excon_response }
      let(:excon_response) { Excon::Response.new body: body, status: 200 }
      let(:page_hash) do
        {
          "entries" => [{
            "id"   => id,
            "guid" => "1234"
          }]
        }
      end

      it { is_expected.to be_a_kind_of Creatable }

      describe "Attributes" do
        it { is_expected.to have_attributes(endpoint: nil) }
        it { is_expected.to have_attributes(fields: Fields) }
        it { is_expected.to have_attributes(id: nil) }
        it { is_expected.to have_attributes(service: nil) }
      end

      describe "Class methods" do
        it { expect(described_class).to respond_to(:create) }
        it { expect(described_class).to respond_to(:load_by_id).with_keywords :user, :id }

        describe '::self.load_by_id' do
          let(:user) { Parameters.user }
          let(:entries) { [{ "id" => "http://data.media.theplatform.com/data/Media/1", "guid" => "123" }] }
          let(:params) { { user: user, id: id } }

          before do
            allow(described_class).to receive(:new).and_return new_entry
            allow(Cts::Mpx::Services::Data).to receive(:get).and_return(response)
          end

          it { is_expected.to require_keyword_arguments(:load_by_id, params) }

          it { expect { described_class.load_by_id user: 1, id: id }.to raise_argument_error(1, User) }
          it { expect { described_class.load_by_id user: user, id: 1 }.to raise_unless_reference(1, String) }

          it "is expected to create a new entry" do
            described_class.load_by_id user: user, id: id
            expect(described_class).to have_received(:new)
          end

          it "is expected to set the id" do
            e = described_class.load_by_id user: user, id: id
            expect(e.id).to eq id
          end

          it "is expected to call entry.load" do
            allow(new_entry).to receive(:load).and_return new_entry
            described_class.load_by_id user: user, id: 'http://data.media.theplatform.com/media/data/Media/1'
            expect(new_entry).to have_received(:load)
          end

          it { is_expected.to be_a_kind_of described_class }
        end
      end

      describe "Instance methods" do
        it { is_expected.to respond_to(:load).with_keywords :user, :fields }
        it { is_expected.to respond_to(:save).with_keywords :user }
        it { is_expected.to respond_to(:to_h) }

        describe '::id' do
          context "when the argument is not a reference" do
            it { expect { new_entry.id = 'no' }.to raise_error ArgumentError, /is not a valid reference/ }
          end

          it "is expected to set service" do
            new_entry.id = id
            expect(new_entry.service).to eq 'Media Data Service'
          end

          it "is expected to set endpoint" do
            new_entry.id = id
            expect(new_entry.endpoint).to eq 'Media'
          end
          it "is expected to build an id field" do
            new_entry.id = id
            expect(new_entry.fields['id']).to eq id
          end
        end

        describe '::load' do
          let(:user) { Parameters.user }
          let(:fields) { 'id,guid' }
          let(:params) { { user: user, fields: fields } }

          before do
            new_entry.service = 'Media Data Service'
            new_entry.endpoint = 'Media'
            new_entry.id = id
          end

          context "when the user is not provided" do
            it { expect { new_entry.load user: nil, fields: 'abc' }.to raise_error ArgumentError, /is a required keyword/ }
          end

          context "when user is not a valid user" do
            it { expect { new_entry.load user: 1, fields: fields }.to raise_error ArgumentError, /is not a valid Cts::Mpx::User/ }
          end

          context "when fields is not a valid String" do
            it { expect { new_entry.load user: user, fields: [] }.to raise_error ArgumentError, /is not a valid String/ }
          end

          it "is expected to call Data.get with user, and fields set" do
            allow(Cts::Mpx::Services::Data).to receive(:get).and_return response
            new_entry.load user: user, fields: fields
            expect(Cts::Mpx::Services::Data).to have_received(:get).with user: user, service: service, endpoint: endpoint, fields: fields, ids: '1'
          end

          it "is expected to call Fields.parse data, xml" do
            allow(Cts::Mpx::Services::Data).to receive(:get).and_return response
            allow(new_entry.fields).to receive(:parse).and_return nil
            new_entry.load user: user, fields: fields
            expect(new_entry.fields).to have_received(:parse).with(data: { "id" => id, "guid" => "1234" }, xmlns: nil)
          end

          it "is expected to return a response" do
            allow(Cts::Mpx::Services::Data).to receive(:get).and_return response
            expect(entry.load(user: user)).to be_a_kind_of Cts::Mpx::Driver::Response
          end
        end

        shared_examples 'save_constraints' do
          context "when the user is not provided" do
            it { expect { entry.save user: nil }.to raise_error ArgumentError, /is a required keyword/ }
          end

          context "when user is not a valid user" do
            it { expect { entry.save user: 1 }.to raise_error ArgumentError, /is not a valid Cts::Mpx::User/ }
          end
        end

        describe '::save (when ID is not set)' do
          let(:entry) { new_entry }
          let(:user) { Parameters.user }
          let(:page) { Driver::Page.create entries: [entry], xmlns: entry.fields.xmlns }

          before do
            entry.service = 'Media Data Service'
            entry.endpoint = 'Media'
            entry.fields.add guid_field
            entry.fields.add custom_field

            allow(Services::Data).to receive(:post).and_return response
            allow(Driver::Page).to receive(:create).and_return page
          end

          include_examples 'save_constraints'

          context "when service is not set" do
            before { entry.service = nil }

            it { expect { entry.save user: user }.to raise_error ArgumentError, /is a required keyword/ }
          end

          context "when endpoint is not set" do
            before { entry.endpoint = nil }

            it { expect { entry.save user: user }.to raise_error ArgumentError, /is a required keyword/ }
          end

          it "is expected to create a page populated with data" do
            entry.save user: user
            expect(Driver::Page).to have_received(:create).with(entries: [{ "guid" => "abcdef", "$uuid" => "abcdef" }], xmlns: { "custom"=>"uuid" })
          end

          it "is expected to call Data.post with with user, service, endpoint, and page" do
            allow(Services::Data).to receive(:post).and_return ''
            entry.save user: user
            expect(Services::Data).to have_received(:post).with(user: user, service: service, endpoint: endpoint, page: page)
          end

          it "is expected to return a response" do
            allow(Services::Data).to receive(:post).and_return response
            expect(entry.save(user: user)).to be response
          end
        end

        describe '::save (when ID is set)' do
          let(:entry) { new_entry }
          let(:user) { Parameters.user }
          let(:page) { Driver::Page.create entries: [entry], xmlns: entry.fields.xmlns }

          before do
            entry.id = id
            entry.service = 'Media Data Service'
            entry.endpoint = 'Media'
            entry.fields.add guid_field
            entry.fields.add custom_field

            allow(Services::Data).to receive(:put).and_return response
            allow(Driver::Page).to receive(:create).and_return page
          end

          include_examples 'save_constraints'

          it "is expected to create a page populated with data" do
            entry.save user: user
            expect(Driver::Page).to have_received(:create).with(entries: [{ "id" => "http://data.media.theplatform.com/data/Media/1", "guid" => "abcdef", "$uuid" => "abcdef" }], xmlns: { "custom"=>"uuid" })
          end

          it "is expected to call Data.post with with user, service, endpoint, and page" do
            allow(Services::Data).to receive(:put).and_return ''
            entry.save user: user
            expect(Services::Data).to have_received(:put).with(user: user, service: service, endpoint: endpoint, page: page)
          end

          it "is expected to return self" do
            expect(entry.save(user: user)).to be response
          end
        end
      end
    end
  end
end
