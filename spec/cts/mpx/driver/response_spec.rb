require 'spec_helper'

module Cts
  module Mpx
    module Driver
      describe Response do
        metadata[:attributes] = { original: nil }
        let(:attributes) { { original: nil } }

        let(:response) { Cts::Mpx::Driver::Response.create original: excon_response }
        let(:excon_response) { Excon::Response.new body: body, headers: headers, status: 200 }
        let(:headers) do
          { "Access-Control-Allow-Origin" => "*",
            "X-Cache"                     => "MISS from data.media.theplatform.com:80",
            "Cache-Control"               => "max-age=0",
            "Date"                        => "Tue, 15 May 2018 00:25:24 GMT",
            "Content-Type"                => "application/json; charset=UTF-8",
            "Content-Length"              => "2050",
            "Server"                      => "Jetty(8.1.16.2)" }
        end
        let(:service_exception) do
          {
            "title"            => "ObjectNotFoundException",
            "description"      => "Could not find object with ID q",
            "isException"      => true,
            "responseCode"     => 404,
            "correlationId"    => "9a23ea0a-0975-4633-9af0-5f7fe3e83f2b",
            "serverStackTrace" => "com.theplatform.data.api.exception.ObjectNotFoundException: ..."
          }
        end

        let(:body) { Oj.dump page_hash }
        let(:page_hash) do
          {
            "$xmlns"       => {
              "pl1" => "http://access.auth.theplatform.com/data/Account/2051509925"
            },
            "startIndex"   => 1,
            "itemsPerPage" => 1,
            "entryCount"   => 1,
            "entries"      => [
              {
                "id"      => "http://data.media.theplatform.com/media/data/AccountSettings/357280835864",
                "guid"    => "cxotgIy9yxyqcr6ccO8DCe56lDkbqTSe",
                "added"   => 1_415_856_204_000,
                "ownerId" => "http://access.auth.theplatform.com/data/Account/2460535675"
              }
            ]
          }
        end

        describe "Attributes" do
          metadata[:attributes].each do |attrib, default_value|
            it "is expected to have attribute #{attrib} set to #{default_value}" do
              expect(subject).to have_attributes attrib => default_value
            end
          end
        end

        describe "Class method signatures" do
          it "is expected to respond to :create with keywords #{metadata[:attributes].keys}" do
            expect(described_class).to respond_to(:create)
          end
        end

        describe "Instance method signatures" do
          it { is_expected.to respond_to(:data).with(0).arguments }
          it { is_expected.to respond_to(:healthy?).with(0).arguments }
          it { is_expected.to respond_to(:page).with(0).arguments }
          it { is_expected.to respond_to(:status).with(0).arguments }
        end

        describe "#data" do
          context "when healthy? is false" do
            before { excon_response.params[:status] = 500 }

            it "is expected to raise an exception" do
              expect { response.data }.to raise_error RuntimeError, 'response does not appear to be healthy'
            end
          end

          context "when original.body is not serializable" do
            before { excon_response.params[:body] = 'no.' }

            it "is expected to raise an exception" do
              expect { response.data }.to raise_error(RuntimeError, /could not parse data/)
            end
          end

          it "is expected to call Oj.load against original.body" do
            allow(Oj).to receive(:load).and_call_original
            response.data
            expect(Oj).to have_received(:load).with(body)
          end

          it "is expected to return a hash" do
            expect(response.data).to be_a_kind_of Hash
          end
        end

        describe "#healthy?" do
          context "when original.status is not 2xx or 3xx" do
            before { excon_response.params[:status] = 500 }

            it "is expected to return false" do
              expect(response.healthy?).to eq false
            end
          end

          it "is expected to return true" do
            expect(response.healthy?).to eq true
          end
        end

        describe "#service_exception?" do
          context "when the isException field is true" do
            before { excon_response.params[:body] = Oj.dump service_exception }

            it "is expected to return true" do
              expect(response.service_exception?).to eq true
            end
          end

          it "is expected to return false" do
            expect(response.service_exception?).to be false
          end
        end

        describe "#page" do
          context "when healthy? is false" do
            before { excon_response.params[:status] = 500 }

            it "is expected to raise an exception" do
              expect { response.page }.to raise_error RuntimeError, 'response does not appear to be healthy'
            end
          end

          it "is expected to call Page.create with the entries and xmlns values extracted from the body." do
            allow(Page).to receive(:create)
            response.page
            expect(Page).to have_received(:create).with entries: page_hash['entries'], xmlns: page_hash['$xmlns']
          end

          it "is expected to return an instance of Page" do
            expect(response.page).to be_a_kind_of Cts::Mpx::Driver::Page
          end
        end

        describe "#status" do
          it "is expected to return the status code of the response" do
            expect(response.status).to eq 200
          end

          it "is expected to be an Integer" do
            expect(response.status).to be_a_kind_of Integer
          end
        end
      end
    end
  end
end
