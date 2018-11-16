require 'spec_helper'

module Cts
  module Mpx
    module Driver
      describe Service do
        let(:account_id) { account_id }
        let(:root_account_id) { 'urn:theplatform:auth:root' }
        let(:service) { Services['User Data Service'] }
        let(:url) { "https://identity.auth.theplatform.com/idm" }

        describe "Attributes" do
          it { is_expected.to have_attributes(endpoints: []) }
          it { is_expected.to have_attributes(form: "") }
          it { is_expected.to have_attributes(name: "") }
          it { is_expected.to have_attributes(path: "") }
          it { is_expected.to have_attributes(read_only: false) }
          it { is_expected.to have_attributes(schema: "") }
          it { is_expected.to have_attributes(search_schema: "") }
          it { is_expected.to have_attributes(type: nil) }
          it { is_expected.to have_attributes(uri_hint: "") }
        end

        describe "Instance method signatures" do
          it { is_expected.to respond_to(:url).with(0..1).argument }
          it { is_expected.to respond_to(:url?).with(0..1).argument }
        end

        describe "::url" do
          context 'when the account_id is not an account_id' do
            let(:account_id) { 'no' }

            it { expect { service.url(account_id) }.to raise_unless_account_id(account_id) }
          end

          context "when the account_id is not provided" do
            it "is expected to use the root account" do
              allow(Registry.domains).to receive(:[]).and_call_original
              service.url
              expect(Registry.domains).to have_received(:[]).with(root_account_id)
            end
          end

          context "when the Registry.domain does not contain the account_id" do
            it "is expected to return nil"  do
              expect(service.url(account_id)).to eq nil
            end
          end

          it "is expected to return the url" do
            expect(service.url).to eq url
          end
        end

        describe "::url?" do
          context 'when the account_id is not an account_id' do
            let(:account_id) { 'no' }

            it { expect { service.url(account_id) }.to raise_unless_account_id(account_id) }
          end

          context "when the account_id is not provided" do
            it "is expected to use the root account" do
              allow(Registry.domains).to receive(:[]).and_call_original
              service.url?
              expect(Registry.domains).to have_received(:[]).with(root_account_id)
            end
          end

          context "when the url is not available" do
            it 'is expected to return false' do
              expect(service.url?(account_id)).to eq false
            end
          end

          it "is expected to return true" do
            expect(service.url?).to eq true
          end
        end
      end
    end
  end
end
