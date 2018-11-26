require 'spec_helper'

module Cts
  module Mpx
    describe Query do
      include_context "with fields objects"
      include_context "with media objects"
      include_context "with user objects"
      include_context "with empty objects"
      include_context "with request and response objects"

      before do
        allow(described_class).to receive(:new).and_return query
        allow(Cts::Mpx::Services::Data).to receive(:get).and_return(populated_response)
      end

      it { is_expected.to be_a_kind_of Creatable }

      describe "Attributes" do
        it { is_expected.to have_attributes(account_id: nil) }
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

      describe "Responds to" do
        it { expect(described_class).to respond_to(:create) }
        it { is_expected.to respond_to(:entries).with(0).arguments }
        it { is_expected.to respond_to(:to_h).with(0).arguments.and_keywords(:include_entries) }
        it { is_expected.to respond_to(:run).with(0).arguments.and_keywords(:user) }
      end

      describe "::entries" do
        before do
          query.service = media_service
          query.endpoint = media_endpoint
        end

        it "is expected to return an Entries class" do
          query.run user: user
          expect(query.entries).to be_a_kind_of Entries
        end

        it "is expected to include the entries from the page" do
          query.run user: user
          expect(query.page.to_mpx_entries.first.to_h).to eq media_entry.to_h
        end
      end

      describe "::run" do
        before do
          query.service = media_service
          query.endpoint = media_endpoint
        end

        it { expect { query.run user: 1 }.to raise_argument_exception(1, User) }

        context "when service is not set" do
          before { query.instance_variable_set :@service, nil }

          it "is expected to raise a runtime error with service must be set" do
            expect { query.run user: user }.to raise_error RuntimeError, /service must be set/
          end
        end

        context "when endpoint is not set" do
          before { query.instance_variable_set :@endpoint, nil }

          it "is expected to raise a runtime error with endpoint must be set" do
            expect { query.run user: user }.to raise_error RuntimeError, /endpoint must be set/
          end
        end

        it "is expected to call Data.get with ..." do
          allow(Services::Data).to receive(:get).and_return response
          query.run user: user
          expect(Services::Data).to have_received(:get).with(user: user, count: false, entries: true, endpoint: media_endpoint, service: media_service, query: {})
        end

        it "is expected to set the response.page to @page" do
          expect { query.run user: user }.to change(query, :page).to a_kind_of(Driver::Page)
        end
      end

      describe "::to_h" do
        before { Query.create(service: media_service, endpoint: media_endpoint).run(user: user) }

        it "is expected to include key params with currently set params" do
          expect(query.to_h[:params]).to eq query.send :params
        end

        it "is expected to include entries" do
          expect(query.to_h[:params]).to include(:entries)
        end

        it "is expected to be a hash" do
          expect(query.to_h).to be_a_kind_of Hash
        end

        context "when include_entries is false" do
          it "is expected to not include key entries" do
            expect(query.to_h(include_entries: false)).not_to include(:entries)
          end
        end
      end
    end
  end
end
