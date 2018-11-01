require 'spec_helper'

module Cts
  module Mpx
    module Driver
      describe Request do
        it { is_expected.to be_a_kind_of Creatable }

        describe "Instance method signatures" do
          it { is_expected.to respond_to(:call).with(0).argument }
        end

        describe '#call' do
          let(:request_method) { :get }
          let(:request) { Request.create method: request_method, url: Parameters.account_id }
          let(:socket) { Excon.new Parameters.account_id }
          let(:excon_response) { Excon::Response.new }

          before do
            allow(Excon).to receive(:new).and_return(socket)
            allow(socket).to receive(request_method).and_return(excon_response)
          end

          context "when method is not :get, :delete, :put, or :post" do
            before { request.method = :not_get }

            it "is expected to raise an exception with, /is not a valid method/" do
              expect { request.call }.to raise_error RuntimeError, /#{request.method} is not a valid method/
            end
          end

          context "when the :url is not a valid reference" do
            before { request.url = 'not_a_url' }

            it "is expected to raise an exception" do
              expect { request.call }.to raise_error RuntimeError, /#{request.url} is not a valid reference/
            end
          end

          context "when payload is supplied" do
            before { request.payload = '{}' }

            it "is expected to pass the payload in as the body." do
              allow(socket).to receive(:get).and_return(excon_response)
              request.call
              expect(socket).to have_received(:get).with(query: {}, body: "{}", path: "/data/Account/1", headers: {})
            end
          end

          context "when query is supplied" do
            before { request.query = { one: 1 } }

            it "is expected to pass the query into the request" do
              allow(socket).to receive(:get).and_return(excon_response)
              request.call
              expect(socket).to have_received(:get).with(query: { one: 1 }, path: "/data/Account/1", headers: {})
            end
          end

          it "is expected to call Connections[] for a connection" do
            allow(Connections).to receive(:[]).and_call_original
            request.call
            expect(Connections).to have_received(:[]).with Parameters.account_id
          end

          it "is expected to call connection with the provided method" do
            request.call
            expect(socket).to have_received(request_method)
          end

          it "is expected to call Response.create with the response" do
            allow(Response).to receive(:create)
            request.call
            expect(Response).to have_received(:create).with(original: excon_response)
          end

          it "is expected to set the attribute response to the Response" do
            expect { request.call }.to change(request, :response).to a_kind_of Response
          end

          it "is expected to return an instance of Response" do
            expect(request.call).to be_a_kind_of Response
          end
        end
      end
    end
  end
end
