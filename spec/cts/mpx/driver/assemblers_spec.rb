require 'spec_helper'

module Cts
  module Mpx
    module Driver
      describe Assemblers do
        include_context "with web parameters"

        let(:user) { User.create username: 'a', password: 'a', token: 'token' }

        describe "Module method signatures" do
          it { expect(described_class).to respond_to(:host).with_keywords :user, :service }
          it { expect(described_class).to respond_to(:path).with_keywords :service, :endpoint, :ids, :extra_path }
          it { expect(described_class).to respond_to(:query).with_keywords :user, :account_id, :service, :endpoint, :query }
        end

        describe "::host" do
          let(:params) { { user: user, service: 'Publish Data Service' } }
          let(:host) { "http://data.publish.theplatform.com" }
          let(:result_hash) do
            {
              "resolveDomainResponse" => {
                "Publish Data Service" => "http://data.publish.theplatform.com/publish"
              }
            }
          end

          before { Registry.initialize }

          it { is_expected.to require_keyword_arguments(:host, params) }
          it { expect { described_class.host(params) }.to raise_error_without_user_token(params[:user]) }

          context "when the service reference does not present a url" do
            it "is expected to use the result from the registry" do
              expect(described_class.host(params)).to eq "http://data.publish.theplatform.com"
            end
          end

          it "is expected to return the host" do
            expect(described_class.host(params)).to eq host
          end
        end

        describe "::path" do
          let(:params) { { service: web_service, endpoint: web_endpoint } }

          it { is_expected.to require_keyword_arguments(:path, params) }

          context "when extra path is provided" do
            before { params[:extra_path] = 'extra_path' }

            it "will be appended to the path" do
              expect(described_class.path(params)).to eq '/idm/web/Authentication/extra_path'
            end
          end

          context "when ids is provided" do
            before { params[:ids] = "1,2,3,4" }

            it "is expected to include them in the path" do
              expect(described_class.path(params)).to eq "/idm/web/Authentication/1,2,3,4"
            end
          end

          context "when the service is a data service" do
            before do
              params[:service] = 'Media Data Service'
              params[:endpoint] = 'Media'
            end

            it "is expected to append /feed to the path" do
              expect(described_class.path(params)).to eq '/media/data/Media/feed'
            end
          end

          it "is expected to find the service in the service reference by name and endpoint" do
            allow(Services).to receive(:[]).and_call_original
            described_class.path params
            expect(Services).to have_received(:[])
          end

          it "is expected to return the assembled path" do
            expect(described_class.path(params)).to eq '/idm/web/Authentication'
          end
        end

        describe "::query" do
          let(:params) { { user: user, service: web_service, endpoint: web_endpoint } }

          it { expect { described_class.query(params) }.to raise_error_without_user_token(params[:user]) }
          it { is_expected.to require_keyword_arguments(:query, params) }
          it { expect(described_class.query(params)).to include(form: 'json') }

          context 'when query is provided' do
            before { params[:query] = { schema: '1.5' } }

            it 'is expected to merge the values in' do
              expect(described_class.query(params)).to include(schema: '1.5')
            end

            it 'is expected to override any provided values' do
              expect(described_class.query(params)).not_to include(schema: '1.1')
            end
          end

          context "when account is provided" do
            let(:account_id) { "http://access.auth.theplatform.com/data/Account/1" }

            before { params[:account_id] = account_id }

            it "is expected to set account" do
              expect(described_class.query(params)).to include(account: account_id)
            end
          end

          it "is expected to set schema to the latest schema" do
            expect(described_class.query(params)).to include(schema: '1.1')
          end

          it "is expected to look up the service in the service reference" do
            allow(Services).to receive(:[]).and_call_original
            described_class.query params
            expect(Services).to have_received(:[])
          end

          it "is expected to set token" do
            expect(described_class.query(params)).to include(token: user.token)
          end

          it "is expected to return the assembled query" do
            expect(described_class.query(params)).to eq(token: "token", schema: "1.1", form: "json")
          end

          it "is expected to return a hash" do
            expect(described_class.query(params)).to be_a_kind_of Hash
          end
        end

        describe "::query_data" do
          let(:params) { { range: nil, count: nil, entries: nil, sort: nil } }

          shared_examples "extra_parameter" do |param, value|
            before { params[param] = value }

            context "when #{param} is provided" do
              it 'is expected to include the value in query' do
                expect(described_class.query_data(params)).to include(param => value)
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
