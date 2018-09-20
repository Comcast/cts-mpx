require 'spec_helper'

module Cts
  module Mpx
    describe Driver do
      it { is_expected.to respond_to(:load_json_file).with(1).arguments }
      it { is_expected.to respond_to(:gem_dir).with(0).arguments }
      it { is_expected.to respond_to(:config_dir).with(0).arguments }

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

      describe "::load_json_file" do
        subject { described_class.load_json_file filename }

        let(:filename) { 'test_file.json' }
        let(:content) { '{"one": 1}' }
        let(:hash) { Oj.load content }

        before do
          allow(File).to receive(:exist?).with(filename).and_return(true)
          allow(File).to receive(:read).with(filename).and_return(content)
        end

        context "when file is not found" do
          before { allow(File).to receive(:exist?).with(filename).and_return(false) }

          it { expect { described_class.load_json_file filename }.to raise_error(/#{filename} does not exist/) }
        end

        context "when it is not parsable json" do
          before { allow(File).to receive(:read).with(filename).and_return('.') }

          it { expect { described_class.load_json_file filename }.to raise_error(/#{filename}:.*line.*column/) }
        end

        context "when the file is readable json" do
          it { is_expected.to be_instance_of Hash }
          it "is expected equal the contents of the file" do
            expect(subject).to eq hash
          end
        end
      end
    end
  end
end
