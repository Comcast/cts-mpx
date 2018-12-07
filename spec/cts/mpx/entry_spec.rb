require 'spec_helper'

module Cts
  module Mpx
    describe Entry do
      include_context "with parameters"
      include_context "with field objects"
      include_context "with media objects"
      include_context "with page objects"
      include_context "with empty objects"

      let(:data) { { id: media_id } }
      let(:parent_class) { Entry }

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

      describe :load_by_id, required_keywords: %i[user id], keyword_types: { user: User } do
        include_context "with user objects"
        include_context "with request and response objects"

        let(:entries) { [{ "id" => media_id, "guid" => "123" }] }
        let(:call_params) { { user: user, id: media_id } }

        before do
          allow(parent_class).to receive(:new).and_return media_entry
          allow(Cts::Mpx::Services::Data).to receive(:get).and_return(populated_response)
        end

        # include_examples "when the user is not logged in"
        include_examples "when a required keyword isn't set"
        include_examples "when a keyword is not a type of", described_class

        context "when id is not a reference" do
          it "is expected to raise an ArgumentError" do
            expect { parent_class.load_by_id user: user, id: 'a_string' }.to raise_error ArgumentError, /a_string is not a valid reference/
          end
        end
        it { expect { parent_class.load_by_id user: user, id: 1 }.to raise_unless_reference(1, String) }

        it "is expected to create a new entry" do
          parent_class.load_by_id user: user, id: media_id
          expect(parent_class).to have_received(:new)
        end

        it "is expected to set the id" do
          e = parent_class.load_by_id user: user, id: media_id
          expect(e.id).to eq media_id
        end

        it "is expected to call entry.load" do
          allow(entry).to receive(:load).and_return media_entry
          parent_class.load_by_id user: user, id: media_id
          expect(media_entry).to have_received(:load)
        end

        it { expect(parent_class.load_by_id(call_params)).to be_a_kind_of parent_class }
      end

      describe '#id' do
        before { entry.id = media_id }

        it "is expected to set service" do
          expect(entry.service).to eq media_service
        end

        it "is expected to set endpoint" do
          expect(entry.endpoint).to eq 'Media'
        end

        it "is expected to build an id field" do
          expect(entry.fields['id']).to eq media_id
        end

        context "when the argument is not a reference" do
          it { expect { entry.id = 'no' }.to raise_error ArgumentError, /is not a valid reference/ }
        end
      end

      describe '#load' do
        include_context "with user objects"
        include_context "with request and response objects"

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

      describe '#save' do
        include_context "with user objects"
        include_context "with request and response objects"

        before do
          media_entry.fields['ownerId'] = account_id
          allow(Driver::Page).to receive(:create).and_return populated_page
          allow(Services::Data).to receive(:put).and_return populated_response
          allow(Services[media_service]).to receive(:url?).and_return nil
        end

        it "is expected to call Registry.fetch_and_store_domain with the user and account" do
          allow(Registry).to receive(:fetch_and_store_domain).and_return []
          media_entry.save user: user
          expect(Registry).to have_received(:fetch_and_store_domain).with(account_id: account_id, user: user)
        end

        it "is expected to create a page populated with data" do
          media_entry.save user: user
          expect(Driver::Page).to have_received(:create).with populated_page_parameters
        end

        it "is expected to return self" do
          expect(media_entry.save(user: user)).to eq media_entry
        end

        context "when fields['ownerId'] is not set" do
          before { entry.fields['ownerId'] = nil }

          it { expect { entry.save user: user }.to raise_error ArgumentError, "fields['ownerId'] is a required field" }
        end

        context "when id is set" do
          let(:expected_method) { :put }

          it "is expected to call Data.put with user, service, endpoint, and page" do
            allow(Services::Data).to receive(expected_method).and_return populated_response
            media_entry.save user: user
            expect(Services::Data).to have_received(expected_method).with(account_id: account_id, user: user, service: media_service, endpoint: media_endpoint, page: page)
          end
        end

        context "when id is not set" do
          let(:expected_method) { :post }

          before do
            allow(Services::Data).to receive(expected_method).and_return populated_response
            media_entry.instance_variable_set :@id, nil
          end

          it "is expected to call Data.post with user, service, endpoint, and page" do
            allow(Services::Data).to receive(expected_method).and_return populated_response
            media_entry.save user: user
            expect(Services::Data).to have_received(expected_method).with(account_id: account_id, user: user, service: media_service, endpoint: media_endpoint, page: page)
          end
        end

        %i[service endpoint].each do |verb|
          context "when #{verb} is not set" do
            before do
              entry.id = media_id
              entry.fields['ownerId'] = account_id
              entry.instance_variable_set "@#{verb}", nil
            end

            it { expect { entry.save user: user }.to raise_exception_without_required verb }
          end
        end
      end
    end
  end
end
