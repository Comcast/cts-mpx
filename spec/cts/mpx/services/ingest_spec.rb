require 'spec_helper'

module Cts
  module Mpx
    module Services
      describe Ingest do
        include_context "with user objects"
        # include_context "with ingest parameters"
        include_context "with request and response objects"

        it { expect(described_class.class).to be Module }
        it { expect(described_class).to respond_to(:[]).with(0..1).arguments }
        it { expect(described_class).to respond_to(:post).with_keywords :user, :account, :service, :endpoint, :headers, :payload, :extra_path }
        it { expect(described_class).to respond_to(:services).with(0).arguments }

        describe "::[] (addressable method)" do
          let(:service) { 'Ingest Service' }

          context "when the key is not a string" do
            it { expect { described_class[1] }.to raise_argument_exception(1, String) }
          end

          context "when the key is not a service name" do
            it { expect { described_class['1'] }.to raise_argument_exception(nil, Cts::Mpx::Driver::Service) }
          end

          context "when a key is not provided" do
            it { expect(described_class[]).to be_instance_of Array }
          end

          it "is expected to search for services that are type: web only" do
            expect(described_class[].count).to eq 1
          end

          it { expect(described_class[service]).to be_instance_of Driver::Service }
        end

        describe :post, required_keywords: [:user, :service, :endpoint], keyword_types: {headers: Hash} do
          let(:call_method) { :post }
          let(:call_params) do
            {
              user:     user,
              service:  'Ingest Service',
              endpoint: 'Publish',
              payload:  '<mrss> ... <mrss>'
            }
          end
          let(:parent_class) { Cts::Mpx::Services::Ingest }
          let(:request_params) do
            {
              method:  :post,
              url:     "http://ingest.theplatform.com/ingest/Publish",
              payload: '<mrss> ... <mrss>',
              headers: {}
            }
          end

          let(:request) { Driver::Request.new }
          let(:response) { Driver::Response.new }

          before do
            allow(Driver::Request).to receive(:new).and_return request
            allow(request).to receive(:call).and_return response
            Registry.initialize
          end

          include_examples "when the user is not logged in"
          include_examples "when a required keyword isn't set"
          include_examples "when a keyword is not a type of", described_class

          {
            host:    { user: User, service: String },
            path:    { service: String, endpoint: String, extra_path: nil }
          }.each do |assembler, required_arguments|
            it "is expected to call Assemblers:#{assembler} with #{required_arguments.keys}" do
              allow(Driver::Assemblers).to receive(assembler).and_call_original
              parent_class.send described_class, call_params
              expect(Driver::Assemblers).to have_received(assembler).with a_hash_including required_arguments
            end
          end

          it "is expected to call Request.create with POST with url, query, and payload" do
            allow(Driver::Request).to receive(:create).and_call_original
            parent_class.post call_params
            expect(Driver::Request).to have_received(:create).with(request_params)
          end

          it "is expected to call request.call" do
            parent_class.post call_params
            expect(request).to have_received(:call)
          end

          it "is expected to return a Response object" do
            expect(parent_class.post(call_params)).to be_a_kind_of Driver::Response
          end
        end

        describe '::service' do
          it "is expected to search for services that are type: ingest only" do
            expect(described_class.services.count).to eq 1
          end
        end
      end
    end
  end
end
