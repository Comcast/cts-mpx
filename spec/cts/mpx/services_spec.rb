require 'spec_helper'

module Cts
  module Mpx
    describe Services do
      let(:user) { Parameters.user }
      let(:service_name) { 'Access Data Service' }

      describe "Attributes" do
        it { is_expected.to have_attributes(reference: an_instance_of(Hash)) }
        it { is_expected.to have_attributes(types: %i[web data ingest]) }
      end

      describe "Module method signatures" do
        it { is_expected.to respond_to(:[]).with(0..1).arguments }
        it { is_expected.to respond_to(:load_reference_file).with_keywords(:file, :file) }
        it { is_expected.to respond_to(:load_references).with(0).arguments }
        it { is_expected.to respond_to(:load_services).with(0).arguments }
        it { is_expected.to respond_to(:reference).with(0..1).arguments }
      end

      describe '::[]' do
        let(:result) { described_class[service_name] }

        context "when the key is not a string" do
          it { expect { described_class[1] }.to raise_error(/key must be a string/) }
        end

        context "when the key is not a service name" do
          it { expect { described_class['1'] }.to raise_error(/must be a service name/) }
        end

        context "when a key is not provided" do
          let(:result) { described_class[] }

          it { expect(result).to be_instance_of Array }
        end

        it { expect(result).to be_instance_of Driver::Service }
      end

      describe '::from_url' do
        let(:id) { 'http://data.media.theplatform.com/media/data/Media/1' }

        context "when the argument is not valid" do
          it "is expected to return nil" do
            expect(described_class.from_url('askjfdaldfkj')).to eq nil
          end
        end

        it "is expected to return a hash with a service: ServiceObject and endpoint: String" do
          expect(described_class.from_url(id)).to eq(service: 'Media Data Service', endpoint: 'Media')
        end
      end

      describe '::initialize' do
        before do
          allow(Cts::Mpx::Services).to receive(:load_references).and_return({})
          allow(Cts::Mpx::Services).to receive(:load_services).and_return({})
          described_class.initialize
        end

        it "is expected to call load_references" do
          expect(Cts::Mpx::Services).to have_received(:load_references).once
        end

        it "is expected to call load_services" do
          expect(Cts::Mpx::Services).to have_received(:load_services).once
        end
      end

      describe '::load_reference_file' do
        let(:result) { described_class.load_reference_file type: 'data', file: 'file' }

        before do
          allow(Driver).to receive(:load_json_file).and_return({})
        end

        context "when type is not supplied" do
          it { expect { described_class.load_reference_file file: 'file' }.to raise_error(ArgumentError, 'type must be supplied') }
        end

        context "when file is not supplied" do
          it { expect { described_class.load_reference_file type: 'data' }.to raise_error(ArgumentError, 'file must be supplied') }
        end

        ['web', 'data', 'ingest'].each do |type|
          it "is expected to set reference[type] to the result of Driver.load_json_file" do
            expect(described_class.raw_reference[type]).to be_instance_of Hash
          end
        end

        it { expect(result).to be true }
      end

      describe '::load_references' do
        it "is expected to change references" do
          expect { described_class.load_references }.to change(described_class, :reference)
        end
      end

      describe '::load_services' do
        before { described_class.load_references }

        it "is expected to change []" do
          expect { described_class.load_services }.to change(described_class, :[])
        end

        context "when the service reference has a url" do
          it "is expected to set service url" do
            # get to cheat here and not set anything up.   This endpoint is the only reason we (currently) have url code.
            expect(Services.reference['web']['Access Data Service']['url']).to eq "http://access.auth.theplatform.com"
          end
        end
      end

      describe '::reference' do
        let(:reference_name) { 'Test Data Service' }
        let(:result) { described_class.reference reference_name }
        let(:reference) do
          {
            reference_name => { service_name => {} }
          }
        end

        before { described_class.raw_reference.merge! reference }

        it { expect(result).to be_instance_of Hash }

        context "when the key is not a string" do
          it { expect { described_class.reference 1 }.to raise_error(/key must be a string/) }
        end

        context "when the key is not included in the reference library" do
          it { expect { described_class.reference '1' }.to raise_error(/is not in the reference library./) }
        end

        context "when a key is not provided" do
          let(:result) { described_class.reference }

          it { expect(result).to be_instance_of Hash }
        end
      end
    end
  end
end
