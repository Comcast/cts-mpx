require 'spec_helper'

module Cts
  module Mpx
    module Services
      describe Web do
        include_context "with user objects"
        include_context "with web parameters"
        include_context "with request and response objects"

        it { expect(described_class.class).to be Module }

        describe "Module method signatures" do
          it { expect(described_class).to respond_to(:[]).with(0..1).arguments }
          it { expect(described_class).to respond_to(:assemble_payload).with_keywords :service, :endpoint, :method, :arguments }
          it { expect(described_class).to respond_to(:post).with_keywords :user, :account, :service, :endpoint, :method, :query, :arguments, :headers, :extra_path }
          it { expect(described_class).to respond_to(:services).with(0).arguments }
        end

        describe "::[] (addressable method)" do
          let(:service) { 'User Data Service' }

          context "when the key is not a string" do
            it { expect { described_class[1] }.to raise_argument_error(1, String) }
          end

          context "when the key is not a service name" do
            it { expect { described_class['1'] }.to raise_argument_error(nil, Cts::Mpx::Driver::Service) }
          end

          context "when a key is not provided" do
            it { expect(described_class[]).to be_instance_of Array }
          end

          it "is expected to equal Web.services (web type only)" do
            expect(described_class[]).to eq described_class.services
          end

          it { expect(described_class[service]).to be_instance_of Driver::Service }
        end

        describe "::assemble_payload" do
          it "is expected to look up the service in the service reference" do
            allow(Services).to receive(:[]).and_call_original
            described_class.assemble_payload web_assembler_parameters
            expect(Services).to have_received(:[]).with web_assembler_parameters[:service]
          end

          it { is_expected.to require_keyword_arguments(:assemble_payload, web_assembler_parameters) }

          context "when the method is not valid" do
            before { web_assembler_parameters[:method] = 'yabadabado' }

            it { expect { described_class.assemble_payload web_assembler_parameters }.to raise_error ArgumentError, /is not a valid method/ }
          end

          context "when any argument is not valid" do
            before { web_assembler_parameters[:arguments] = { yaba: 'daba', doo: 'doo' } }

            it { expect { described_class.assemble_payload web_assembler_parameters }.to raise_error ArgumentError, /is not a valid argument/ }
          end

          it "is expected to embed the method on the first tier as a hash" do
            expect(described_class.assemble_payload(web_assembler_parameters).keys).to eq [web_assembler_parameters[:method]]
          end

          it "is expected to embed the argument on the second tier" do
            expect(described_class.assemble_payload(web_assembler_parameters)[web_assembler_parameters[:method]]).to eq web_assembler_parameters[:arguments]
          end

          it "is expected to return a hash" do
            expect(described_class.assemble_payload(web_assembler_parameters)).to be_a_kind_of Hash
          end
        end


        describe "::post" do
          let(:call_method) { :post }
          let(:request_params) do
            {
              method:  call_method,
              url:     "https://identity.auth.theplatform.com/idm/web/Authentication",
              query:   {
                token:  user_token,
                schema: "1.1",
                form:   "json"
              },
              payload: "{\"signIn\":{\"username\":\"#{user_name}\",\"password\":\"#{user_password}\"}}",
              headers: {}
            }
          end

          before do
            allow(Driver::Request).to receive(:new).and_return request
            allow(request).to receive(:call).and_return response
            Registry.initialize
          end

          it { expect { described_class.post(web_post_parameters) }.to raise_error_without_user_token }
          it { is_expected.to require_keyword_arguments(:post, web_post_parameters) }

          include_examples 'registry_check', :post

          include_examples 'call_assembler', :host, %i[user service]
          include_examples 'call_assembler', :path, %i[service endpoint]
          include_examples 'call_assembler', :query, %i[user service endpoint query]

          it "is expected to call Request.create with POST with url, query, and payload" do
            allow(Driver::Request).to receive(:create).and_call_original
            described_class.post web_post_parameters
            expect(Driver::Request).to have_received(:create).with(request_params)
          end

          it "is expected to call request.call" do
            described_class.post web_post_parameters
            expect(request).to have_received(:call)
          end

          it "is expected to return a Response object" do
            expect(described_class.post(web_post_parameters)).to be_a_kind_of Driver::Response
          end
        end

        describe '::service' do
          it "is expected to search for services that are type: web only" do
            expect(described_class.services.count).to eq 13
          end
        end
      end
    end
  end
end
