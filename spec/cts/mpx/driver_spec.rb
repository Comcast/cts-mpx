require 'spec_helper'

module Cts
  module Mpx
    describe Driver do
      it { is_expected.to respond_to(:config_dir).with(0).arguments }
      it { is_expected.to respond_to(:gem_dir).with(0).arguments }
      it { is_expected.to respond_to(:parse_json).with(1).arguments }

      describe "Exceptions" do
        it { expect(described_class.constants).to include(:TokenError, :ServiceError, :ConnectionError, :CredentialsError) }
      end

      describe "::config_dir" do
        it "is expected to return the gem_dir + 'config'" do
          allow(described_class).to receive(:gem_dir).and_return('.')
          expect(described_class.config_dir).to eq "./config"
        end
      end

      describe "::gem_dir" do
        context "when the gem is found in Gem.loaded_specs" do
          let(:specification) do
            Gem::Specification.new do |s|
              s.name = 'cts-mpx'
              s.version = Cts::Mpx::VERSION
            end
          end

          it "is expected to return the specification's gem directory." do
            allow(Gem).to receive(:loaded_specs).and_return('cts-mpx' => specification)
            expect(described_class.gem_dir).to eq(specification.gem_dir)
          end
        end

        it "is expected to be the current directory" do
          expect(described_class.gem_dir).to eq Dir.pwd
        end
      end

      describe "::parse_json" do
        let(:filename) { 'filename' }
        let(:content) { '{"one": 1}' }
        let(:hash) { Oj.load content }

        it { expect(described_class.parse_json(content)).to be_instance_of Hash }

        context "when it is not parsable json" do
          it { expect { described_class.parse_json '.' }.to raise_error(/.: unexpected character/) }
        end
      end
    end
  end
end
