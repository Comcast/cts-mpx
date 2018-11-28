require 'spec_helper'

module Cts
  module Mpx
    module Driver
      describe Page do
        let(:params) { { "entries" => [], "xmlns" => {} } }
        let(:page) { Page.new }

        it { is_expected.to be_a_kind_of Enumerable }
        it { is_expected.to be_a_kind_of Page }
        it { is_expected.to be_a_kind_of Creatable }
        it { is_expected.to have_attributes(entries: an_instance_of(Array)) }
        it { is_expected.to have_attributes(xmlns: an_instance_of(Hash)) }
        it { is_expected.to respond_to(:to_s).with(1).arguments }

        describe "::to_s" do
          let(:entries) { [{ "id" => "http://data.media.theplatform.com/media/data/Media/1", "guid" => "123" }] }
          let(:xmlns)   { { "ns" => "a_value" } }
          let(:params)  { { xmlns: xmlns, entries: entries } }
          let(:string_params) { { "xmlns" => xmlns, "entries" => entries } }
          let(:output)  { Oj.dump string_params }
          let(:page)    { Page.create params }
          let(:input)   { Oj.load page.to_s }

          context "when any argument is provided" do
            let(:output) { Oj.dump string_params, indent: 2 }

            it "is expected to return indented output" do
              expect(page.to_s(true)).to eq output
            end
          end

          it "is expected to output xmlns first" do
            expect(input.keys).to eq ['xmlns', 'entries']
          end

          it { expect(input).to be_a_kind_of Hash }

          it "is expected to look like this" do
            expect(page.to_s).to eq output
          end
        end
      end
    end
  end
end
