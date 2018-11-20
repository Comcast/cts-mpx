require 'spec_helper'

module Cts::Mpx::Services
  describe Data do
    include_context "with data parameters"
    include_context "with request and response objects"
    include_context "with media objects"
    include_context "with user objects"

    let(:root_domain) { Driver.load_json_file('config/root_registry_sea1.json')['resolveDomainResponse'] }
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

    describe '::delete' do
      let(:call_method) { :delete }

      include_examples 'call_constraints'
      include_examples 'call_request', :delete
    end

    describe "::get" do
      let(:call_method) { :get }

      context "when fields is provided" do
        before { call_params[:fields] = 'id,guid' }

        it "is expected to pass them to Request.call" do
          allow(Driver::Request).to receive(:create).and_call_original
          described_class.send call_method, call_params
          expect(Driver::Request).to have_received(:create).with(a_hash_including(query: a_hash_including(fields: call_params[:fields])))
        end
      end

      include_examples 'call_constraints'
      include_examples 'call_request', :get
    end

    shared_context "with data call setup" do
      let(:call_params) { { user: user, service: service, endpoint: endpoint, query: {} } }
      let(:call_parent) { Cts::Mpx::Services::Data }
      let(:create_with_params) { { method: described_class, url: "http://data.media.theplatform.com/media/data/Media/feed", query: { form: "cjson", schema: "1.7.0", token: "carpe diem" }, headers: {} } }

      before do
        call_params[:page] = Driver::Page.create
        create_with_params[:payload] = Oj.dump('xmlns' => {}, 'entries' => [])
      end
    end

    [:put, :post].each do |verb|
      describe verb, method: verb, focus: true, required_keywords: ['user', 'service', 'endpoint', 'page'], keyword_types: { user: User, query: Hash, page: Driver::Page } do
        include_context "with data call setup", described_class
        include_examples "when the user is not logged in", described_class
        include_examples "when a required keyword isn't set", described_class
        include_examples "when a keyword is not a type of", described_class

        it { expect(call_parent.send described_class, (call_params)).to be_a_kind_of(Driver::Response) }

        it "is expected to call Assemblers::host with user, service" do
          allow(Driver::Assemblers).to receive(:host).and_call_original
          call_parent.send described_class,  call_params
          expect(Driver::Assemblers).to have_received(:host).with service: service, user: user
        end

        it "is expected to call Assemblers::path with service, endpoint, and extra_path" do
          allow(Driver::Assemblers).to receive(:path).and_call_original
          call_parent.send described_class,  call_params
          expect(Driver::Assemblers).to have_received(:path).with service: service, endpoint: endpoint, extra_path: nil
        end

        it "is expected to call Assemblers::query with user, service, endpoint, query" do
          allow(Driver::Assemblers).to receive(:query).and_call_original
          call_parent.send described_class,  call_params
          expect(Driver::Assemblers).to have_received(:query).with account_id: nil, service: service, user: user, endpoint: endpoint, query: {}
        end

        it "is expected to call assembler_payload"

        it "is expected to call Request.create with '...'" do
          allow(Driver::Request).to receive(:create).and_call_original
          call_parent.send described_class, call_params
          expect(Driver::Request).to have_received(:create).with create_with_params
        end

        it "is expected to call request.call" do
          call_parent.send described_class, call_params
          expect(request).to have_received(:call).with(no_args)
        end
      end
    end

    describe "::post", method: :post, required_keywords: ['user', 'service', 'endpoint', 'page'], keyword_types: { user: User, query: Hash, page: Driver::Page } do
      include_context "with data call setup", metadata[:method]
      include_examples "when the user is not logged in"
      include_examples "when a required keyword isn't set"
      include_examples "when a keyword is not a type of"

      it { expect(Data.post(call_params)).to be_a_kind_of(Driver::Response) }

      it "is expected to call Assemblers::host with user, service" do
        allow(Driver::Assemblers).to receive(:host).and_call_original
        Data.post call_params
        expect(Driver::Assemblers).to have_received(:host).with service: service, user: user
      end

      it "is expected to call Assemblers::path with service, endpoint, and extra_path" do
        allow(Driver::Assemblers).to receive(:path).and_call_original
        Data.post call_params
        expect(Driver::Assemblers).to have_received(:path).with service: service, endpoint: endpoint, extra_path: nil
      end

      it "is expected to call Assemblers::query with user, service, endpoint, query" do
        allow(Driver::Assemblers).to receive(:query).and_call_original
        Data.post call_params
        expect(Driver::Assemblers).to have_received(:query).with account_id: nil, service: service, user: user, endpoint: endpoint, query: {}
      end

      it "is expected to call assembler_payload"

      it "is expected to call Request.create with '...'" do
        allow(Driver::Request).to receive(:create).and_call_original
        Data.post call_params
        expect(Driver::Request).to have_received(:create).with create_with_params
      end

      it "is expected to call request.call" do
        Data.post call_params
        expect(request).to have_received(:call).with(no_args)
      end
    end

    describe "::put" do
      let(:call_method) { :put }

      before do
        call_params[:page] = Driver::Page.create
        create_with_params[:payload] = Oj.dump(xmlns: {}, entries: [])
      end

      include_examples 'call_constraints'
      include_examples 'call_request', :put
    end
  end
end
