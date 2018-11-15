require 'spec_helper'

module Cts
  module Mpx
    describe Entry do
      include_context "with basic parameters"
      include_context "with field and fields"

      let(:data) { { id: media_id } }
      let(:empty_entry) { described_class.new }

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

        let(:entries) { [{ "id" => media_id, "guid" => "123" }] }

        before do
          allow(described_class).to receive(:new).and_return media_entry
          allow(Cts::Mpx::Services::Data).to receive(:get).and_return(populated_response)
        end

        it { is_expected.to require_keyword_arguments(:load_by_id, user: user, id: nil) }

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
          allow(empty_entry).to receive(:load).and_return media_entry
          described_class.load_by_id user: user, id: 'http://data.media.theplatform.com/media/data/Media/1'
          expect(media_entry).to have_received(:load)
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
        include_context "with request and response"

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
          allow(Cts::Mpx::Services::Data).to receive(:get).and_return populated_response
          media_entry.load user: user, fields: fields
          expect(Cts::Mpx::Services::Data).to have_received(:get).with account_id: 'urn:theplatform:auth:root', user: user, service: media_service, endpoint: media_endpoint, fields: fields, ids: '1'
        end

        it "is expected to call Fields.parse data, xml" do
          allow(Cts::Mpx::Services::Data).to receive(:get).and_return populated_response
          allow(media_entry.fields).to receive(:parse).and_return nil
          media_entry.load user: user, fields: fields
          expect(media_entry.fields).to have_received(:parse).with(data: { "id" => media_id }, xmlns: {})
        end

        it "is expected to return a response" do
          allow(Cts::Mpx::Services::Data).to receive(:get).and_return populated_response
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
        include_context "with request and response"

        let(:empty_entry) { Cts::Mpx::Entry.new }

        before do
          media_entry.fields['ownerId'] = account_id
          allow(Services::Data).to receive(:put).and_return populated_response
          allow(Driver::Page).to receive(:create).and_return page
        end

        include_examples 'save_constraints'

        it "is expected to create a page populated with data" do
          media_entry.save user: user
          expect(Driver::Page).to have_received(:create).with populated_page_parameters
        end

        it "is expected to call Data.post with with user, service, endpoint, and page" do
          media_entry.instance_variable_set :@id, nil
          allow(Services::Data).to receive(:post).and_return ''
          media_entry.save user: user
          expect(Services::Data).to have_received(:post).with(account_id: account_id, user: user, service: media_service, endpoint: media_endpoint, page: page)
        end

        it "is expected to return self" do
          expect(media_entry.save(user: user)).to be media_entry
        end


        context "when fields['ownerId'] is not set" do

          before { empty_entry.fields['ownerId'] = nil }

          it { expect { empty_entry.save user: user }.to raise_error ArgumentError, "fields['ownerId'] must be set" }
        end

        context "when service is not set" do
          before do
            empty_entry.fields['ownerId'] = account_id
            empty_entry.instance_variable_set :@service, nil
          end

          it { expect { empty_entry.save user: user }.to raise_error ArgumentError, /is a required keyword/ }
        end

        context "when endpoint is not set" do
          before do
            empty_entry.fields['ownerId'] = account_id
            empty_entry.instance_variable_set :@endpoint, nil
          end

          it { expect { empty_entry.save user: user }.to raise_error ArgumentError, /is a required keyword/ }
        end
      end

      describe '#save (when ID is set)' do
        include_context "with user"
        include_context "with request and response"

        before do
          media_entry.fields['ownerId'] = account_id
          allow(Services::Data).to receive(:put).and_return populated_response
          allow(Driver::Page).to receive(:create).and_return page
        end

        include_examples 'save_constraints'

        it "is expected to create a page populated with data" do
          media_entry.save user: user
          expect(Driver::Page).to have_received(:create).with(entries: [media_entry.to_h[:entry]], xmlns: media_entry.fields.xmlns)
        end

        it "is expected to call Data.post with with user, service, endpoint, and page" do
          allow(Services::Data).to receive(:put).and_return ''
          media_entry.save user: user
          expect(Services::Data).to have_received(:put).with(account_id: account_id, user: user, service: media_service, endpoint: media_endpoint, page: page)
        end

        it "is expected to return self" do
          expect(media_entry.save(user: user)).to eq media_entry
        end
      end
    end
  end
end
