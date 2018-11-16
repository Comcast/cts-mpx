require 'spec_helper'

module Cts
  module Mpx
    module Services
      describe Ingest do
        include_context "with user objects"

        it { expect(described_class.class).to be Module }

        describe "Module method signatures" do
          it { expect(described_class).to respond_to(:[]).with(0..1).arguments }
          it { expect(described_class).to respond_to(:post).with_keywords :user, :account, :service, :endpoint, :headers, :payload, :extra_path }
          it { expect(described_class).to respond_to(:services).with(0).arguments }
        end

        describe "::[] (addressable method)" do
          let(:service) { 'Ingest Service' }

          context "when the key is not a string" do
            it { expect { described_class[1] }.to raise_argument_error(1, String) }
          end

          context "when the key is not a service name" do
            it { expect { described_class['1'] }.to raise_argument_error(nil, Cts::Mpx::Driver::Service) }
          end

          context "when a key is not provided" do
            it { expect(described_class[]).to be_instance_of Array }
          end

          it "is expected to search for services that are type: web only" do
            expect(described_class[].count).to eq 1
          end

          it { expect(described_class[service]).to be_instance_of Driver::Service }
        end

        describe "::post" do
          let(:call_method) { :post }
          let(:call_params) do
            {
              user:     user,
              service:  'Ingest Service',
              endpoint: 'Publish',
              payload:  '<mrss> ... <mrss>'
            }
          end

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

          it { expect { described_class.post(call_params) }.to raise_error_without_user_token(call_params[:user]) }
          it { is_expected.to require_keyword_arguments(:post, call_params) }

          include_examples 'registry_check', :post
          include_examples 'call_assembler', :host, %i[user service]
          include_examples 'call_assembler', :path, %i[service endpoint]

          it "is expected to call Request.create with POST with url, query, and payload" do
            allow(Driver::Request).to receive(:create).and_call_original
            described_class.post call_params
            expect(Driver::Request).to have_received(:create).with(request_params)
          end

          it "is expected to call request.call" do
            described_class.post call_params
            expect(request).to have_received(:call)
          end

          it "is expected to return a Response object" do
            expect(described_class.post(call_params)).to be_a_kind_of Driver::Response
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
