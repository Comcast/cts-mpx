require 'spec_helper'

module Cts::Mpx::Services
  describe Data do
    include_context "with data parameters"
    include_context "with request and response objects"
    include_context "with media objects"
    include_context "with user objects"

    let(:parent_class) { Cts::Mpx::Services::Data }
    let(:root_domain) { Driver.parse_json(File.read('config/root_registry_sea1.json'))['resolveDomainResponse'] }
    let(:call_params) { { user: user, service: media_service, endpoint: media_endpoint, query: {} } }
    let(:with_params) { { method: call_method, url: "http://data.media.theplatform.com/media/data/Media/feed", query: { form: "cjson", schema: "1.7.0", token: "carpe diem" }, headers: {} } }

    before do
      allow(Driver::Request).to receive(:new).and_return request
      allow(request).to receive(:call).and_return response
      allow(Registry).to receive(:fetch_and_store_domain).and_return root_domain
      Registry.initialize
    end

    it { expect(described_class.class).to be Module }

    describe "Responds to" do
      it { is_expected.to respond_to(:[]).with(0..1).arguments }
      it { is_expected.to respond_to(:delete).with_keywords(:user, :account_id, :service, :endpoint, :sort, :extra_path, :range, :ids, :query, :headers, :count, :entries) }
      it { is_expected.to respond_to(:get).with_keywords(:user, :account_id, :service, :endpoint, :sort, :extra_path, :range, :ids, :query, :headers, :count, :entries, :fields) }
      it { is_expected.to respond_to(:post).with_keywords(:user, :account_id, :service, :endpoint, :extra_path, :query, :page, :headers) }
      it { is_expected.to respond_to(:put).with_keywords(:user, :account_id, :service, :endpoint, :extra_path, :query, :page, :headers) }
    end

    describe "::[] (addressable method)" do
      let(:service) { 'Media Data Service' }

      context "when the key is not a string" do
        it { expect { described_class[1] }.to raise_error(ArgumentError, /key must be a string/) }
      end

      context "when the key is not a service name" do
        it { expect { described_class['1'] }.to raise_error(ArgumentError, /must be a service name/) }
      end

      context "when a key is not provided" do
        it { expect(described_class[]).to be_instance_of Array }
      end

      it "is expected to search for services that are type: data only" do
        expect(described_class[].count).to eq 29
      end

      it { expect(described_class[service]).to be_instance_of Driver::Service }
    end

    shared_context "with data call setup" do
      let(:call_params) { { user: user, service: service, endpoint: endpoint, query: {} } }
      let(:with_parameters) { { method: described_class, url: "http://data.media.theplatform.com/media/data/Media/feed", query: { form: "cjson", schema: "1.7.0", token: "carpe diem" }, headers: {} } }
    end

    shared_context "with get" do
      let(:call_method) { :get }

      context "when fields is provided" do
        before do
          call_params[:fields] = 'id,guid'
        end

        it "is expected to pass them to Request.call" do
          allow(Driver::Request).to receive(:create).and_call_original
          parent_class.send call_method, call_params
          expect(Driver::Request).to have_received(:create).with(a_hash_including(query: a_hash_including(fields: call_params[:fields])))
        end
      end
    end

    shared_context "with post" do
      include_context "with page objects"

      let(:call_method) { :post }

      metadata[:required_keywords].push :page
      metadata[:keyword_types][:page] = Cts::Mpx::Driver::Page

      before do
        call_params[:page] = page
        with_parameters[:payload] = Oj.dump(page_parameters)
      end
    end

    shared_context "with put" do
      include_context "with post"

      let(:call_method) { :put }
    end

    shared_context "with delete" do
      let(:call_method) { :delete }
    end

    describe_hash = {
      required_keywords: %i[user service endpoint],
      keyword_types:     { user: User, query: Hash, headers: Hash }
    }

    %i[delete get put post].each do |verb|
      describe verb, method: verb, required_keywords: describe_hash[:required_keywords], keyword_types: describe_hash[:keyword_types] do
        include_context "with data call setup", described_class
        include_context "with #{verb}"
        include_examples "when the user is not logged in"
        include_examples "when a required keyword isn't set"
        include_examples "when a keyword is not a type of", described_class

        it { expect(parent_class.send(described_class, call_params)).to be_a_kind_of(Driver::Response) }

        {
          host:  { user: User, service: String },
          path:  { service: String, endpoint: String, extra_path: nil },
          query: { user: User, service: String, endpoint: String, query: Hash }
        }.each do |assembler, required_arguments|
          it "is expected to call Assemblers:#{assembler} with #{required_arguments}" do
            allow(Driver::Assemblers).to receive(assembler).and_call_original
            parent_class.send described_class, call_params
            expect(Driver::Assemblers).to have_received(assembler).with a_collection_including required_arguments
          end
        end

        it "is expected to call Request.create with '...'" do
          allow(Driver::Request).to receive(:create).and_call_original
          parent_class.send described_class, call_params
          expect(Driver::Request).to have_received(:create).with with_parameters
        end

        it "is expected to call request.call" do
          parent_class.send described_class, call_params
          expect(request).to have_received(:call).with(no_args)
        end
      end
    end
  end
end
