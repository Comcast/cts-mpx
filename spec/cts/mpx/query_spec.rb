require 'spec_helper'

module Cts
  module Mpx
    describe Query do
      let(:endpoint) { 'Media' }
      let(:id) { 'http://data.media.theplatform.com/data/Media/1' }
      let(:service) { 'Media Data Service' }

      it { is_expected.to be_a_kind_of described_class }

      describe "Attributes" do
        it { is_expected.to have_attributes(account: nil) }
        it { is_expected.to have_attributes(endpoint: nil) }
        it { is_expected.to have_attributes(extra_path: nil) }
        it { is_expected.to have_attributes(fields: nil) }
        it { is_expected.to have_attributes(ids: nil) }
        it { is_expected.to have_attributes(page: a_kind_of(Driver::Page)) }
        it { is_expected.to have_attributes(query: {}) }
        it { is_expected.to have_attributes(range: nil) }
        it { is_expected.to have_attributes(return_count: false) }
        it { is_expected.to have_attributes(return_entries: true) }
        it { is_expected.to have_attributes(service: nil) }
        it { is_expected.to have_attributes(sort: nil) }
      end

      describe "Class methods" do
        it { expect(described_class).to respond_to(:create) }
      end

      describe "Instance methods" do
        let(:body) { Oj.dump page_hash }
        let(:endpoint) { 'Media' }
        let(:excon_response) { Excon::Response.new body: body, status: 200 }
        let(:id) { 'http://data.media.theplatform.com/data/Media/1' }
        let(:new_entry) { described_class.new }
        let(:page_hash) do
          {
            "entries" => [{
              "id"   => id,
              "guid" => "1234"
            }]
          }
        end
        let(:query) { described_class.new }
        let(:response) { Cts::Mpx::Driver::Response.create original: excon_response }
        let(:service) { 'Media Data Service' }
        let(:user) { Parameters.user }

        before do
          allow(described_class).to receive(:new).and_return new_entry
          allow(Cts::Mpx::Services::Data).to receive(:get).and_return(response)
        end

        it { is_expected.to respond_to(:entries).with(0).arguments }
        it { is_expected.to respond_to(:to_h).with(0).arguments.and_keywords(:include_entries) }
        it { is_expected.to respond_to(:run).with(0).arguments.and_keywords(:user) }

        describe "::entries" do
          before do
            query.service = service
            query.endpoint = endpoint
          end

          it "is expected to call Entries.create_from_page with page" do
            allow(Entries).to receive(:create_from_page).and_call_original
            query.run user: user
            query.entries
            expect(Entries).to have_received(:create_from_page).with a_kind_of Driver::Page
          end
        end

        describe "::run" do
          before do
            query.service = service
            query.endpoint = endpoint
          end

          it { expect { query.run user: 1 }.to raise_argument_error(1, User) }

          context "when service is not set" do
            before { query.service = nil }

            it "is expected to raise a runtime error with service must be set" do
              expect { query.run user: user }.to raise_error RuntimeError, /service must be set/
            end
          end

          context "when endpoint is not set" do
            before { query.endpoint = nil }

            it "is expected to raise a runtime error with endpoint must be set" do
              expect { query.run user: user }.to raise_error RuntimeError, /endpoint must be set/
            end
          end

          it "is expected to call Data.get with ..." do
            allow(Services::Data).to receive(:get).and_return response
            query.run user: user
            expect(Services::Data).to have_received(:get).with(user: user, count: false, entries: true, endpoint: endpoint, service: service, query: {})
          end

          it "is expected to set the response.page to @page" do
            expect { query.run user: user }.to change(query, :page).to a_kind_of(Driver::Page)
          end
        end

        describe "::to_h" do
          before do
            query.service = "Media Data Service"
            query.endpoint = "Media"
            query.run user: user
          end

          context "when include_entries is false" do
            it "is expected to not include key entries" do
              expect(query.to_h(include_entries: false)).not_to include(:entries)
            end
          end

          it "is expected to include key params with currently set params" do
            expect(query.to_h[:params]).to eq query.send :params
          end

          it "is expected to include entries" do
            expect(query.to_h[:params]).to include(:entries)
          end

          it "is expected to be a hash" do
            expect(query.to_h).to be_a_kind_of Hash
          end
        end
      end
    end
  end
end
