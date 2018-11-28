require 'spec_helper'

module Cts
  module Mpx
    module Services
      describe Web do
        include_context "with user objects"
        include_context "with web parameters"
        include_context "with request and response objects"

        it { expect(described_class.class).to be Module }
        it { expect(described_class).to respond_to(:[]).with(0..1).arguments }
        it { expect(described_class).to respond_to(:assemble_payload).with_keywords :service, :endpoint, :method, :arguments }
        it { expect(described_class).to respond_to(:post).with_keywords :user, :account, :service, :endpoint, :method, :query, :arguments, :headers, :extra_path }
        it { expect(described_class).to respond_to(:services).with(0).arguments }

        describe "::[] (addressable method)" do
          let(:service) { 'User Data Service' }

          context "when the key is not a string" do
            it { expect { described_class[1] }.to raise_unless_required_argument(1, String) }
          end

          context "when the key is not a service name" do
            it { expect { described_class['1'] }.to raise_unless_required_argument(nil, Cts::Mpx::Driver::Service) }
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
          include_context "with web parameters"

          it "is expected to look up the service in the service reference" do
            allow(Services).to receive(:[]).and_call_original
            described_class.assemble_payload assembler_params
            expect(Services).to have_received(:[]).with assembler_params[:service]
          end

          %i[service endpoint method arguments].each do |key|
            context "when #{key} is not supplied" do
              before { assembler_params.delete key }

              it { expect { described_class.assemble_payload assembler_params }.to raise_exception_without_required key }
            end
          end

          context "when the method is not valid" do
            before { assembler_params[:method] = 'yabadabado' }

            it { expect { described_class.assemble_payload assembler_params }.to raise_error ArgumentError, /is not a valid method/ }
          end

          context "when any argument is not valid" do
            before { assembler_params[:arguments] = { yaba: 'daba', doo: 'doo' } }

            it { expect { described_class.assemble_payload assembler_params }.to raise_error ArgumentError, /is not a valid argument/ }
          end

          it "is expected to embed the method on the first tier as a hash" do
            expect(described_class.assemble_payload(assembler_params).keys).to eq [assembler_params[:method]]
          end

          it "is expected to embed the argument on the second tier" do
            expect(described_class.assemble_payload(assembler_params)[assembler_params[:method]]).to eq assembler_params[:arguments]
          end

          it "is expected to return a hash" do
            expect(described_class.assemble_payload(assembler_params)).to be_a_kind_of Hash
          end
        end

        describe(:post,
                 required_keywords: ['user', 'service', 'endpoint', 'method', 'arguments'],
                 keyword_types:     { query: Hash, headers: Hash, arguments: Hash }) do
          let(:parent_class) { Cts::Mpx::Services::Web }
          let(:call_method) { :post }
          let(:with_params) do
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

          include_examples "when the user is not logged in"
          include_examples "when a required keyword isn't set"
          include_examples "when a keyword is not a type of", described_class

          it { expect(parent_class.send(described_class, call_params)).to be_a_kind_of(Driver::Response) }

          {
            host:  { user: User, service: String },
            path:  { service: String, endpoint: String, extra_path: nil },
            query: { user: User, service: String, endpoint: String, query: Hash }
          }.each do |assembler, required_arguments|
            it "is expected to call Assemblers:#{assembler} with #{required_arguments.keys}" do
              allow(Driver::Assemblers).to receive(assembler).and_call_original
              parent_class.send described_class, call_params
              expect(Driver::Assemblers).to have_received(assembler).with a_hash_including required_arguments
            end
          end

          it "is expected to call assemble_payload" do
            allow(parent_class).to receive(:assemble_payload).and_return nil
            parent_class.send :assemble_payload, assembler_params
            expect(parent_class).to have_received(:assemble_payload).with assembler_params
          end

          it "is expected to call Request.create with '...'" do
            allow(Driver::Request).to receive(:create).and_call_original
            parent_class.send described_class, call_params
            expect(Driver::Request).to have_received(:create).with with_params
          end

          it "is expected to call request.call" do
            parent_class.send described_class, call_params
            expect(request).to have_received(:call).with(no_args)
          end

          it "is expected to call Request.create with POST with url, query, and payload" do
            allow(Driver::Request).to receive(:create).and_call_original
            parent_class.post call_params
            expect(Driver::Request).to have_received(:create).with(with_params)
          end

          it "is expected to return a Response object" do
            expect(parent_class.post(call_params)).to be_a_kind_of Driver::Response
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
