require 'spec_helper'

module Cts
  module Mpx
    module Driver
      describe Service do
        include_context "with parameters"

        let(:service) { Services[ident_service] }
        let(:url) { ident_endpoint }

        it { is_expected.to have_attributes(endpoints: a_kind_of(Array)) }
        it { is_expected.to have_attributes(form: a_kind_of(String)) }
        it { is_expected.to have_attributes(name: a_kind_of(String)) }
        it { is_expected.to have_attributes(path: a_kind_of(String)) }
        it { is_expected.to have_attributes(read_only: false) }
        it { is_expected.to have_attributes(schema: a_kind_of(String)) }
        it { is_expected.to have_attributes(search_schema: a_kind_of(String)) }
        it { is_expected.to have_attributes(type: nil) }
        it { is_expected.to have_attributes(uri_hint: a_kind_of(String)) }
        it { is_expected.to respond_to(:url).with(0..1).argument }
        it { is_expected.to respond_to(:url?).with(0..1).argument }

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
