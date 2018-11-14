require 'spec_helper'

module Cts
  module Mpx
    describe Entry do
      include_context "with basic parameters"
      include_context "with field and fields"

      let(:data) { { id: media_id } }
      let(:empty_entry) { described_class.new }
      # let(:loadable_hash) { { xmlns: xmlns, entry: data } }
      # let(:body) { Oj.dump page_hash }
      # let(:response) { Cts::Mpx::Driver::Response.create original: excon_response }
      # let(:excon_response) { Excon::Response.new body: body, status: 200 }
      # let(:page_hash) do
      #   {
      #     "entries" => [{
      #       "id"   => media_id,
      #       "guid" => "1234"
      #     }]
      #   }
      # end

      it { is_expected.to be_a_kind_of Creatable }

      describe "Has attributes" do
        it { is_expected.to have_attributes(endpoint: nil) }
        it { is_expected.to have_attributes(fields: Fields) }
        it { is_expected.to have_attributes(id: nil) }
        it { is_expected.to have_attributes(service: nil) }
      end

      describe "Responds to" do
        it { is_expected.to respond_to(:load).with_keywords :user, :fields }
        it { is_expected.to respond_to(:save).with_keywords :user }
        it { is_expected.to respond_to(:to_h) }
        it { expect(described_class).to respond_to(:load_by_id).with_keywords :user, :id }
      end

      describe '::self.load_by_id' do
        include_context "with user"
        include_context "with request and response"

        let(:entries) { [{ "id" => "http://data.media.theplatform.com/media/data/Media/1", "guid" => "123" }] }
        let(:params) { { user: user, id: media_id } }

        before do
          allow(described_class).to receive(:new).and_call_original
          allow(Cts::Mpx::Services::Data).to receive(:get).and_return(populated_response)
        end

        it { is_expected.to require_keyword_arguments(:load_by_id, params) }

        it { expect { described_class.load_by_id user: 1, id: media_id }.to raise_argument_error(1, User) }
        it { expect { described_class.load_by_id user: user, id: 1 }.to raise_unless_reference(1, String) }

        it "is expected to create a new entry" do
          described_class.load_by_id user: user, id: media_id
          expect(described_class).to have_received(:new)
        end

        it "is expected to set the id" do
          e = described_class.load_by_id user: user, id: media_id
          expect(e.id).to eq media_id
        end

        it "is expected to call entry.load" do
          allow(empty_entry).to receive(:load).and_return empty_entry
          described_class.load_by_id user: user, id: 'http://data.media.theplatform.com/media/data/Media/1'
          expect(empty_entry).to have_received(:load)
        end

        it { is_expected.to be_a_kind_of described_class }
      end

      describe '#id' do
        context "when the argument is not a reference" do
          it { expect { empty_entry.id = 'no' }.to raise_error ArgumentError, /is not a valid reference/ }
        end

        it "is expected to set service" do
          empty_entry.id = media_id
          expect(empty_entry.service).to eq media_service
        end

        it "is expected to set endpoint" do
          empty_entry.id = media_id
          expect(empty_entry.endpoint).to eq 'Media'
        end
        it "is expected to build an id field" do
          empty_entry.id = media_id
          expect(empty_entry.fields['id']).to eq media_id
        end
      end

      describe '#load' do
        include_context "with user"

        let(:fields) { 'id,guid' }
        let(:params) { { user: user, fields: fields } }

        context "when the user is not provided" do
          it { expect { media_entry.load user: nil, fields: 'abc' }.to raise_error ArgumentError, /is a required keyword/ }
        end

        context "when user is not a valid user" do
          it { expect { media_entry.load user: 1, fields: fields }.to raise_error ArgumentError, /is not a valid Cts::Mpx::User/ }
        end

        context "when fields is not a valid String" do
          it { expect { media_entry.load user: user, fields: [] }.to raise_error ArgumentError, /is not a valid String/ }
        end

        it "is expected to call Data.get with user, and fields set" do
          allow(Cts::Mpx::Services::Data).to receive(:get).and_return response
          media_entry.load user: user, fields: fields
          expect(Cts::Mpx::Services::Data).to have_received(:get).with account_id: 'urn:theplatform:auth:root', user: user, service: media_service, endpoint: media_endpoint, fields: fields, ids: '1'
        end

        it "is expected to call Fields.parse data, xml" do
          allow(Cts::Mpx::Services::Data).to receive(:get).and_return response
          allow(media_entry.fields).to receive(:parse).and_return nil
          media_entry.load user: user, fields: fields
          expect(media_entry.fields).to have_received(:parse).with(data: { "id" => media_id, "guid" => "1234" }, xmlns: nil)
        end

        it "is expected to return a response" do
          allow(Cts::Mpx::Services::Data).to receive(:get).and_return response
          expect(media_entry.load(user: user)).to be_a_kind_of described_class
        end
      end

      shared_examples 'save_constraints' do
        context "when the user is not provided" do
          it { expect { media_entry.save user: nil }.to raise_error ArgumentError, /is a required keyword/ }
        end

        context "when user is not a valid user" do
          it { expect { media_entry.save user: 1 }.to raise_error ArgumentError, /is not a valid Cts::Mpx::User/ }
        end
      end

      describe '#save (when ID is not set)' do
        include_context "with user"

        let(:entry) { empty_entry }
        let(:page) { Driver::Page.create entries: [entry], xmlns: entry.fields.xmlns }

        before do
          entry.service = media_service
          entry.endpoint = 'Media'
          entry.fields.add field
          entry.fields.add custom_field
          entry.fields['ownerId'] = account_id
          allow(Services::Data).to receive(:post).and_return response
          allow(Driver::Page).to receive(:create).and_return page
        end

        include_examples 'save_constraints'

        it "is expected to create a page populated with data" do
          entry.save user: user
          expect(Driver::Page).to have_received(:create).with(entries: [{ field_name => field_value, custom_field_name => custom_field_value, "ownerId" => account_id }], xmlns: custom_field_xmlns)
        end

        it "is expected to call Data.post with with user, service, endpoint, and page" do
          allow(Services::Data).to receive(:post).and_return ''
          entry.save user: user
          expect(Services::Data).to have_received(:post).with(account_id: account_id, user: user, service: media_service, endpoint: media_endpoint, page: page)
        end

        it "is expected to return a response" do
          allow(Services::Data).to receive(:post).and_return response
          expect(entry.save(user: user)).to be response
        end

        context "when fields['ownerId'] is not set" do
          before { entry.fields['ownerId'] = nil }

          it { expect { entry.save user: user }.to raise_error ArgumentError, "fields['ownerId'] must be set" }
        end

        context "when service is not set" do
          before { entry.instance_variable_set :@service, nil }

          it { expect { entry.save user: user }.to raise_error ArgumentError, /is a required keyword/ }
        end

        context "when endpoint is not set" do
          before { entry.instance_variable_set :@endpoint, nil }

          it { expect { entry.save user: user }.to raise_error ArgumentError, /is a required keyword/ }
        end
      end

      describe '#save (when ID is set)' do
        include_context "with user"

        let(:entry) { empty_entry }
        let(:page) { Driver::Page.create entries: [entry], xmlns: entry.fields.xmlns }

        before do
          entry.id = media_id
          entry.service = media_service
          entry.endpoint = 'Media'
          entry.fields.add field
          entry.fields.add custom_field
          entry.fields['ownerId'] = account_id

          allow(Services::Data).to receive(:put).and_return response
          allow(Driver::Page).to receive(:create).and_return page
        end

        include_examples 'save_constraints'

        it "is expected to create a page populated with data" do
          entry.save user: user
          expect(Driver::Page).to have_received(:create).with(entries: [{ "id" => media_id, "ownerId" => account_id, custom_field_name => custom_field_value, field_name => field_value }], xmlns: custom_field_xmlns)
        end

        it "is expected to call Data.post with with user, service, endpoint, and page" do
          allow(Services::Data).to receive(:put).and_return ''
          entry.save user: user
          expect(Services::Data).to have_received(:put).with(account_id: account_id, user: user, service: media_service, endpoint: media_endpoint, page: page)
        end

        it "is expected to return self" do
          expect(entry.save(user: user)).to be response
        end
      end
    end
  end
end
