require 'spec_helper'

module Cts
  module Mpx
    describe Entries do
      include_context "with media entries"
      include_context "with field"

      let(:other_entries) { Entries.create(collection: [other_entry]) }
      let(:other_entry) { Entry.new }

      it { is_expected.to be_a_kind_of Enumerable }
      it { is_expected.to be_a_kind_of Creatable }
      it { is_expected.to have_attributes(collection: []) }

      describe "Responds to" do
        it { is_expected.to respond_to(:add).with(1).argument }
        it { is_expected.to respond_to(:each) }
        it { is_expected.to respond_to(:remove).with(1).argument }
        it { is_expected.to respond_to(:reset).with(0).arguments }
        it { is_expected.to respond_to(:[]).with(0..1).arguments }
        it { is_expected.to respond_to(:+).with(1).argument }
        it { is_expected.to respond_to(:-).with(1).argument }
      end

      describe '::[] (addressable method)' do
        context "when no key is supplied" do
          it "is expected to return the entire collection" do
            expect(media_entries[]).to eq media_entries.collection
          end
        end

        context "when a value could not be found" do
          it "is expected to return nil" do
            expect(media_entries['aslkdj']).to eq nil
          end
        end

        it "is expected to return the value" do
          media_entry.id = media_id
          expect(media_entries[media_id]).to eq media_entry
        end
      end

      describe '::+' do
        it { expect(media_entries + other_entries).to be_an_instance_of(Entries) }

        it "expected to be the aggreation of the two entries" do
          expect((media_entries + other_entries).collection).to eq [media_entry, other_entry]
        end
      end

      describe '::-' do
        it { expect(media_entries - other_entries).to be_an_instance_of(Entries) }

        it "expected to be the aggreation of the two entries" do
          expect((media_entries - other_entries).collection).to eq [media_entry, other_entry]
        end
      end

      describe '::add' do
        context "when the provided argument is not a kind of #{Entry}" do
          it { expect { media_entries.add 1 }.to raise_argument_error(1, Entry) }
        end

        context 'when the provided entry is already in @collections' do
          it { expect { media_entries.add media_entry }.not_to change(media_entries, :collection) }
        end

        it "is expected to add the argument to @collection" do
          media_entries.remove media_entry
          expect { media_entries.add media_entry }.to change(media_entries, :collection).to([media_entry])
        end

        it "is expected to return self" do
          expect(media_entries.add(media_entry)).to eq media_entries
        end
      end

      describe '::each' do
        specify { expect { |b| media_entries.each(&b) }.to yield_control.once }
      end

      describe '::reset' do
        it { expect { media_entries.reset }.to change(media_entries, :collection).to([]) }
      end

      describe '::remove' do
        context "when the provided field is not a kind of Field" do
          it { expect { media_entries.add 1 }.to raise_argument_error(1, Entry) }
        end

        it { expect { media_entries.remove media_entry }.to change(media_entries, :collection).to([]) }
      end
    end
  end
end
