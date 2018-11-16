require 'spec_helper'

module Cts
  module Mpx
    describe Registry do
      include_context "with user objects"
      include_context "with parameters"

      let(:root_domain) { Driver.load_json_file('config/root_registry_sea1.json')['resolveDomainResponse'] }
      let(:result_hash) { { 'resolveDomainResponse' => root_domain } }

      describe "Attributes" do
        it { is_expected.to have_attributes(domains: an_instance_of(Hash)) }
      end

      describe "Module method signatures" do
        it { expect(described_class).to respond_to(:fetch_and_store_domain).with(2).arguments }
        it { expect(described_class).to respond_to(:fetch_domain).with(2).arguments }
        it { expect(described_class).to respond_to(:store_domain).with(2).arguments }
      end

      describe "::fetch_and_store_domain" do
        before do
          allow(described_class).to receive(:fetch_domain).and_return(root_domain)
          Registry.instance_variable_set(:@domains, root_account_id => root_domain)
        end

        it "is expected to call fetch_domain" do
          described_class.fetch_and_store_domain user, account_id
          expect(described_class).to have_received(:fetch_domain).with(user, account_id)
        end

        it "is expected to call store_domain with the output from fetch_domain" do
          allow(described_class).to receive(:store_domain).and_return nil
          described_class.fetch_and_store_domain user, account_id
          expect(described_class).to have_received(:store_domain).with(root_domain, account_id)
        end

        it "is expected to store the domain in domains" do
          described_class.fetch_and_store_domain user, root_account_id
          expect(described_class.domains).to eq root_account_id => result_hash["resolveDomainResponse"]
        end

        it "is expected to return the domain" do
          expect(described_class.fetch_and_store_domain(user, account_id)).to eq(result_hash["resolveDomainResponse"])
        end
      end

      describe "::fetch_domain" do
        include_context "with response objects"
        include_context "with user objects"

        let(:post_params) do
          {
            user:      user,
            service:   'Access Data Service',
            endpoint:  'Registry',
            method:    'resolveDomain',
            arguments: { 'accountId' => account_id }
          }
        end

        let(:post_response_string) do
          '{
            "resolveDomainResponse": {
              "Message Data Service": "http://data.message.theplatform.com/message",
              "User Data Service":    "https://identity.auth.theplatform.com/idm"
            }
          }'
        end

        before do
          response.instance_variable_set :@data, Oj.load(post_response_string)
          allow(Services::Web).to receive(:post).and_return response
        end

        it { expect { described_class.fetch_domain user, account_id }.to raise_error_without_user_token(user) }

        it "is expected to call Web.post" do
          described_class.fetch_domain(user, account_id)
          expect(Services::Web).to have_received(:post).with(post_params)
        end

        it "is expected to return the value of 'resolveDomainResponse'" do
          expect(described_class.fetch_domain(user, account_id)).to eq Oj.load(post_response_string)["resolveDomainResponse"]
        end

        context "when the user is not a Cts::Mpx::User object" do
          it { expect { described_class.fetch_domain '1', account_id }.to raise_argument_error(1, 'User') }
        end

        context "when the account_id is not a valid account_id" do
          it { expect { described_class.fetch_domain user, '1' }.to raise_argument_error(1, 'account_id') }
        end

        context "when no account_id is supplied" do
          it "is expected to return the root account_id (urn:theplatform:auth:root)" do
            expect(described_class.fetch_domain(user, root_account_id)).to eq described_class.domains[root_account_id]
          end
        end
      end

      describe "::initialize" do
        let(:file) { 'config/root_registry.sea1.json' }

        # this effectively re-initializes things without calling initialize or store_domain.
        after { Registry.instance_variable_set(:@domains, root_account_id => root_domain) }

        before do
          allow(Driver).to receive(:load_json_file).with(/#{file}/).and_return(result_hash)
        end

        it "is expected to call File.read with 'config/root_registry.sea1.json'" do
          described_class.initialize
          expect(Driver).to have_received(:load_json_file)
        end

        it "is expected to call store_domain with root_account_id and the hash" do
          allow(described_class).to receive(:store_domain).and_return(result_hash)
          described_class.initialize
          expect(described_class).to have_received(:store_domain).with(root_domain, root_account_id)
        end
      end

      describe "::store_domain" do
        context "when the account_id is not a valid account_id" do
          it { expect { described_class.fetch_domain user, '1' }.to raise_argument_error(1, 'account_id') }
        end

        context "when the data is not a Hash object" do
          let(:result_hash) { 'not_a_hash' }

          it { expect { described_class.store_domain(result_hash, account_id) }.to raise_argument_error(result_hash, Hash) }
        end

        it "is expected to store the result_hash in domains" do
          described_class.store_domain(result_hash['resolveDomainResponse'], account_id)
          expect(described_class.instance_variable_get(:@domains)[account_id]).to eq result_hash['resolveDomainResponse']
        end

        it "is expected to return nil" do
          expect(described_class.store_domain(result_hash, account_id)).to be_nil
        end
      end
    end
  end
end
