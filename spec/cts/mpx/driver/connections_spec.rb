require 'spec_helper'

module Cts
  module Mpx
    module Driver
      describe Connections do
        include_context "with parameters"
        let(:uri) { account_id }
        let(:connection) { Excon.new uri }

        before { allow(Excon).to receive(:new).and_call_original }
        after { described_class.initialize }

        it { expect(described_class).to have_attributes(collection: Array) }
        it { expect(described_class).to respond_to(:[]).with(1).argument }
        it { expect(described_class).to respond_to(:create_connection).with(1).argument }

        describe "::initialize" do
          it "is expected to set the default headers (content-type, user-agent, content-encoding)" do
            expect(Excon.defaults[:headers]).to match a_hash_including(
              "Content-Type"     => 'application/json',
              "User-Agent"       => a_string_including("cts-mpx").and(a_string_including(Cts::Mpx::VERSION)),
              'Content-Encoding' => 'bzip2,xz,gzip,deflate'
            )
          end

          it "is expected to initialize the collection" do
            described_class.initialize
            expect(described_class.collection).to eq []
          end
        end

        describe "::create_connection" do
          it "is expected to create a new excon object" do
            described_class[uri]
            expect(Excon).to have_received(:new).with([URI.parse(uri).scheme, URI.parse(uri).host].join('://'), any_args)
          end

          it "is expected to be a persistent connection" do
            expect(connection.params[:persistent]).to be true
          end
        end

        describe "::[] (addressable operator)" do
          let(:connection) { described_class[account_id] }

          it "is expected to index by host" do
            expect(described_class[uri]).to match a_kind_of Excon::Connection
          end

          it "is expected to return an Excon object" do
            expect(described_class[uri]).to match a_collection_including(Excon::Connection)
          end

          context "when collection does not contain a connection for the host" do
            it "is expected to call create_collection with uri" do
              described_class[uri]
              expect(Excon).to have_received(:new).with([URI.parse(uri).scheme, URI.parse(uri).host].join('://'), any_args)
            end
          end

          context "when no argument is provided it" do
            before { described_class.create_connection(URI.parse(uri)) }

            it { expect(described_class[]).to be_a_kind_of Array }
            it { expect(described_class[]).to match a_collection_including a_kind_of Excon::Connection }
          end

          context "when the url is not a lexically equivalent URI (rfc 3986) it" do
            let(:bad_uri) { 'not a uri' }

            it { expect { described_class[bad_uri] }.to raise_error(ArgumentError).with_message(/\(#{bad_uri}\) is not a uri/) }
          end

          context "when the host does not contain theplatform in it" do
            let(:uri) { 'http://www.comcast.net' }

            it { expect { described_class[uri] }.to raise_error(ArgumentError).with_message(/\(#{uri}\) does not contain theplatform in it./) }
          end
        end
      end
    end
  end
end
