require 'spec_helper'

module Cts::Mpx
  describe Registry do
    include_context "with user objects"
    include_context "with parameters"

    let(:file) { 'config/root_registry_sea1.json' }
    let(:root_domain) { Driver.parse_json(File.read file)[hash_key] }
    let(:hash_key) { 'resolveDomainResponse' }
    let(:hash_value) { root_domain }
    let(:result_hash) { { hash_key => hash_value } }
    let(:parent_class) { Cts::Mpx::Registry }
    let(:described_method) { described_class }

    after { Registry.initialize }

    it { is_expected.to have_attributes(domains: an_instance_of(Hash)) }
    it { expect(parent_class).to respond_to(:fetch_and_store_domain).with(2).arguments }
    it { expect(parent_class).to respond_to(:fetch_domain).with(2).arguments }
    it { expect(parent_class).to respond_to(:store_domain).with(2).arguments }

    describe :fetch_and_store_domain do
      before do
        allow(parent_class).to receive(:fetch_domain).and_return(root_domain)
        Registry.instance_variable_set(:@domains, root_account_id => root_domain)
      end

      it "is expected to call fetch_domain" do
        parent_class.fetch_and_store_domain user, account_id
        expect(parent_class).to have_received(:fetch_domain).with(user, account_id)
      end

      it "is expected to call store_domain with the output from fetch_domain" do
        allow(parent_class).to receive(:store_domain).and_return nil
        parent_class.fetch_and_store_domain user, account_id
        expect(parent_class).to have_received(:store_domain).with(root_domain, account_id)
      end

      it "is expected to store the domain in domains" do
        parent_class.fetch_and_store_domain user, root_account_id
        expect(parent_class.domains).to eq root_account_id => result_hash["resolveDomainResponse"]
      end

      it "is expected to return the domain" do
        expect(parent_class.fetch_and_store_domain(user, account_id)).to eq(result_hash["resolveDomainResponse"])
      end
    end

    describe :fetch_domain do
      include_context "with response objects"
      include_context "with user objects"

      let(:call_params) do
        {
          user:      user,
          service:   'Access Data Service',
          endpoint:  'Registry',
          method:    'resolveDomain',
          arguments: { 'accountId' => account_id }
        }
      end

      before do
        response.instance_variable_set :@data, result_hash
        allow(Services::Web).to receive(:post).and_return response
      end

      it { expect { parent_class.fetch_domain user, account_id }.to raise_error_without_user_token(user) }

      it "is expected to call Web.post" do
        parent_class.fetch_domain(user, account_id)
        expect(Services::Web).to have_received(:post).with(call_params)
      end

      it "is expected to return the value of hash_key" do
        expect(parent_class.fetch_domain(user, account_id)).to eq hash_value
      end

      context "when the user is not a Cts::Mpx::User object" do
        it { expect { parent_class.fetch_domain '1', account_id }.to raise_argument_exception(1, 'User') }
      end

      context "when the account_id is not a valid account_id" do
        it { expect { parent_class.fetch_domain user, '1' }.to raise_argument_exception(1, 'account_id') }
      end

      context "when no account_id is supplied" do
        it "is expected to return the root account_id (urn:theplatform:auth:root)" do
          expect(parent_class.fetch_domain(user, root_account_id)).to eq parent_class.domains[root_account_id]
        end
      end
    end

    describe :initialize do
      before { allow(Driver).to receive(:parse_json).and_return(result_hash) }

      it { expect(parent_class.initialize).to eq nil }

      it "is expected to call File.read with 'config/root_registry.sea1.json'" do
        parent_class.initialize
        expect(Driver).to have_received(:parse_json)
      end

      it "is expected to call store_domain with root_account_id and the hash" do
        allow(parent_class).to receive(:store_domain).and_return(result_hash)
        parent_class.initialize
        expect(parent_class).to have_received(:store_domain).with(root_domain, root_account_id)
      end
    end

    describe :store_domain do
      it { expect(parent_class.store_domain(result_hash, account_id)).to be_nil }

      it "is expected to store the result_hash in domains" do
        parent_class.store_domain(result_hash[hash_key], account_id)
        expect(parent_class.instance_variable_get(:@domains)[account_id]).to eq result_hash[hash_key]
      end

      it { expect { parent_class.store_domain user, '1' }.to raise_argument_exception(1, 'account_id') }
      it { expect { parent_class.store_domain('not_a_hash', account_id) }.to raise_argument_exception('not_a_hash', Hash) }
    end
  end
end
