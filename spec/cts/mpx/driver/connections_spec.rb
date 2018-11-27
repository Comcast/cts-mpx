require 'spec_helper'

module Cts
  module Mpx
    module Driver
      describe Connections do
        include_context "with parameters"
        let(:uri) { account_id }
        let(:connection) { Excon.new uri }

        before { allow(Excon).to receive(:new).and_return(connection) }

        it { expect(described_class).to respond_to(:[]).with(1).argument }

        describe "::[] (addressable operator)" do
          let(:connection) { described_class[account_id] }

          # TODO next: add a method for 'create_connection' to encapsulate most of these tests
          # replace it with a call create check in ::[]
          it { expect(connection.params).to match a_hash_including(persistent: true)}
          it "is expected to be a persistent connection" do
            expect(connection.params[:persistent]).to be true
          end

          it "is expected to set content-type in the headers to json" do
            expect(connection.params[:headers]).to include("Content-Type" => 'application/json')
          end

          it "is expected to set user agent in the headers to cts-mpx ruby sdk version #{Cts::Mpx::VERSION}" do
            expect(connection.params[:headers]).to include("User-Agent" => "cts-mpx ruby sdk version #{Cts::Mpx::VERSION}")
          end

          it "is expected to set content-encoding in the headers to bzip2,xz,gzip,deflate" do
            expect(connection.params[:headers]).to include("Content-Encoding" => 'bzip2,xz,gzip,deflate')
          end

          it "is expected to index by host" do
            expect(described_class[uri]).to be connection
          end

          it "is expected to return an Excon object" do
            expect(described_class[uri]).to be_a_kind_of(Excon::Connection)
          end

          context "when open_connections does not contain a connection for the host" do
            it "is expected to create a new one" do
              described_class[uri]
              expect(Excon).to have_received(:new).with([URI.parse(uri).scheme, URI.parse(uri).host].join('://'), any_args)
            end
          end

          context "when no argument is provided it" do
            before do
              allow(Excon).to receive(:new).and_call_original
              described_class.instance_variable_set :@open_connections, [connection]
            end

            it { expect(described_class[]).to match a_collection_including Excon::Connection }
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
