require 'spec_helper'

module Cts
  module Mpx
    module Driver
      describe Assemblers do
        include_context "with parameters"
        include_context "with data parameters"
        include_context "with user objects"

        let(:parent_class) { Assemblers }

        it { expect(described_class).to respond_to(:host).with_keywords :user, :service }
        it { expect(described_class).to respond_to(:path).with_keywords :service, :endpoint, :ids, :extra_path }
        it { expect(described_class).to respond_to(:query).with_keywords :user, :account_id, :service, :endpoint, :query }

        describe ".host" do
          let(:host) { "http://data.media.theplatform.com" }
          let(:host3) { "http://data.media3.theplatform.com" }
          let(:params) { { user: user, service: service } }
          let(:subject) { proc { Assemblers.host params } }

          before { Registry.initialize }

          it { is_expected.to raise_error_without_user_token(user) }

          context "when the service includes a shard numeric (Media Data Service 3)" do
            let(:service) { "Media Data Service 3" }

            it { result_is_expected.to eq host3 }
          end

          context "when the service is a media service" do
            it { result_is_expected.to eq host }
          end

          context "when the user is not provided" do
            let(:params) { { service: service }}

            it { is_expected.to raise_error ArgumentError, /user is a required keyword/ }
          end

          context "when the service is not provided" do
            let(:params) { { user: user }}

            it { is_expected.to raise_error ArgumentError, /service is a required keyword/ }
          end
        end

        describe :path, required_keywords: %i[service endpoint] do
          let(:call_params) { { service: service, endpoint: endpoint } }
          let(:prefix) { '/media/data/Media' }

          include_examples "when a required keyword isn't set"

          it "is expected to find the service in the service reference by name and endpoint" do
            allow(Services).to receive(:[]).and_call_original
            parent_class.path call_params
            expect(Services).to have_received(:[])
          end

          it "is expected to return the assembled path" do
            expect(parent_class.path(call_params)).to eq prefix + '/feed'
          end

          context "when extra path is provided" do
            before { call_params[:extra_path] = 'extra_path' }

            it "will be appended to the path" do
              expect(parent_class.path(call_params)).to eq "#{prefix}/extra_path/feed"
            end
          end

          context "when ids is provided" do
            before { call_params[:ids] = "1,2,3,4" }

            it "is expected to include them in the path" do
              expect(parent_class.path(call_params)).to eq "#{prefix}/feed/#{call_params[:ids]}"
            end
          end

          context "when the service is a data service" do
            before do
              call_params[:service] = service
              call_params[:endpoint] = endpoint
            end

            it "is expected to append /feed to the path" do
              expect(parent_class.path(call_params)).to eq '/media/data/Media/feed'
            end
          end
        end

        describe :query, required_keywords: %i[user service endpoint] do
          let(:call_params) { { user: user, service: service, endpoint: endpoint, range: nil, count: nil, entries: nil, sort: nil } }

          include_examples "when a required keyword isn't set"

          it { expect { parent_class.query(call_params) }.to raise_error_without_user_token(call_params[:user]) }
          it { expect(parent_class.query(call_params)).to be_a_kind_of Hash }

          it "is expected to look up the service in the service reference" do
            allow(Services).to receive(:[]).and_call_original
            parent_class.query call_params
            expect(Services).to have_received(:[])
          end

          context 'when schema (1.5) is provided' do
            before { call_params[:query] = { schema: '1.5' } }

            it { expect(parent_class.query(call_params)).to match a_hash_including schema: String }
          end

          context "when account is provided" do
            before { call_params[:account_id] = account_id }

            it { expect(parent_class.query(call_params)).to match a_hash_including account: String }
          end

          { range: '1-1', count: true, entries: true, sort: 'DESC' }.each do |param, value|
            before { call_params[param] = value }

            context "when #{param} is provided" do
              it { expect(parent_class.query(call_params)).to include(param => a_kind_of(value.class)) }
            end
          end
        end
      end
    end
  end
end
