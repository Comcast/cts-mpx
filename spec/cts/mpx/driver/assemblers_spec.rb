require 'spec_helper'

module Cts
  module Mpx
    module Driver
      describe Assemblers do
        include_context "with web parameters"
        include_context "with user objects"

        let(:parent_class) { Assemblers }

        describe "Module method signatures"do
          it { expect(described_class).to respond_to(:host).with_keywords :user, :service }
          it { expect(described_class).to respond_to(:path).with_keywords :service, :endpoint, :ids, :extra_path }
          it { expect(described_class).to respond_to(:query).with_keywords :user, :account_id, :service, :endpoint, :query }
        end

        describe :host, required_keywords: %i{user service} do
          let(:call_params) { { user: user, service: 'Publish Data Service' } }
          let(:host) { "http://data.publish.theplatform.com" }
          let(:result_hash) do
            {
              "resolveDomainResponse" => {
                "Publish Data Service" => "http://data.publish.theplatform.com/publish"
              }
            }
          end

          before { Registry.initialize }

          include_examples "when a required keyword isn't set"
          include_examples "when the user is not logged in"

          it { expect { parent_class.host(call_params) }.to raise_error_without_user_token(call_params[:user]) }

          it "is expected to return the host" do
            expect(parent_class.host(call_params)).to eq host
          end

          context "when the service reference does not present a url" do
            it "is expected to use the result from the registry" do
              expect(parent_class.host(call_params)).to eq host
            end
          end
        end

        describe :path, required_keywords: [:service, :endpoint] do
          let(:call_params) { { service: service, endpoint: endpoint } }

          include_examples "when a required keyword isn't set"

          context "when extra path is provided" do
            before { call_params[:extra_path] = 'extra_path' }

            it "will be appended to the path" do
              expect(parent_class.path(call_params)).to eq '/idm/web/Authentication/extra_path'
            end
          end

          context "when ids is provided" do
            before { call_params[:ids] = "1,2,3,4" }

            it "is expected to include them in the path" do
              expect(parent_class.path(call_params)).to eq "/idm/web/Authentication/1,2,3,4"
            end
          end

          context "when the service is a data service" do
            include_context "with media parameters"

            before do
              call_params[:service] = media_service
              call_params[:endpoint] = media_endpoint
            end

            it "is expected to append /feed to the path" do
              expect(parent_class.path(call_params)).to eq '/media/data/Media/feed'
            end
          end

          it "is expected to find the service in the service reference by name and endpoint" do
            allow(Services).to receive(:[]).and_call_original
            parent_class.path call_params
            expect(Services).to have_received(:[])
          end

          it "is expected to return the assembled path" do
            expect(parent_class.path(call_params)).to eq '/idm/web/Authentication'
          end
        end

        describe :query, required_keywords: [:user, :service, :endpoint] do
          let(:call_params) { { user: user, service: service, endpoint: endpoint } }

          include_examples "when a required keyword isn't set"

          it { expect { parent_class.query(call_params) }.to raise_error_without_user_token(call_params[:user]) }

          it { expect(parent_class.query(call_params)).to include(form: 'json') }

          it "is expected to set schema to the latest schema" do
            expect(parent_class.query(call_params)).to include(schema: '1.1')
          end

          it "is expected to look up the service in the service reference" do
            allow(Services).to receive(:[]).and_call_original
            parent_class.query call_params
            expect(Services).to have_received(:[])
          end

          it "is expected to set token" do
            expect(parent_class.query(call_params)).to include(token: user.token)
          end

          it "is expected to return the assembled query" do
            expect(parent_class.query(call_params)).to eq(token: user.token, schema: "1.1", form: "json")
          end

          it "is expected to return a hash" do
            expect(parent_class.query(call_params)).to be_a_kind_of Hash
          end

          context 'when query is provided' do
            before { call_params[:query] = { schema: '1.5' } }

            it 'is expected to merge the values in' do
              expect(parent_class.query(call_params)).to include(schema: '1.5')
            end

            it 'is expected to override any provided values' do
              expect(parent_class.query(call_params)).not_to include(schema: '1.1')
            end
          end

          context "when account is provided" do
            let(:account_id) { "http://access.auth.theplatform.com/data/Account/1" }

            before { call_params[:account_id] = account_id }

            it "is expected to set account" do
              expect(parent_class.query(call_params)).to include(account: account_id)
            end
          end
        end

        describe "::query_data" do
          let(:call_params) { { range: nil, count: nil, entries: nil, sort: nil } }

          shared_examples "extra_parameter" do |param, value|
            before { call_params[param] = value }

            context "when #{param} is provided" do
              it 'is expected to include the value in query' do
                expect(parent_class.query_data(call_params)).to include(param => value)
              end
            end
          end

          include_examples 'extra_parameter', :range, '1-1'
          include_examples 'extra_parameter', :count, true
          include_examples 'extra_parameter', :entries, true
          include_examples 'extra_parameter', :sort, 'DESC'
        end
      end
    end
  end
end
