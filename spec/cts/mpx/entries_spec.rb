require 'spec_helper'

module Cts
  module Mpx
    describe Entries do
      describe "Ancestors" do
        it { is_expected.to be_a_kind_of Enumerable }
        it { is_expected.to be_a_kind_of described_class }
      end

      describe "Attributes" do
        it { is_expected.to have_attributes(collection: []) }
      end

      describe "Class methods" do
        let(:params)  { { xmlns: { "ns": "a_value" }, entries: [{ "id" => Parameters.account_id, "guid" => "123" }] } }
        let(:page)    { Driver::Page.create params }

        describe 'Signatures' do
          it { expect(described_class).to respond_to(:create) }
          it { expect(described_class).to respond_to(:create_from_page).with(1).arguments }
        end

        describe '::create_from_page' do
          it { expect { described_class.create_from_page 1 }.to raise_argument_error(1, Driver::Page) }

          context 'when the field "id" is present' do
            let(:entry) { Entry.new }

            it "is expected to set entry.id with entry.field['id']" do
              allow(Entry).to receive(:new).and_return entry
              expect { described_class.create_from_page page }.to change(entry, :id).to Parameters.account_id
            end
          end

          it "is expected to call page.entries.each" do
            allow(page.entries).to receive(:each).and_call_original
            described_class.create_from_page page
            expect(page.entries).to have_received(:each)
          end

          it "is expected to call #{Entries}.new " do
            allow(Entries).to receive(:new).and_call_original
            described_class.create_from_page page
            expect(Entries).to have_received(:new)
          end

          it "is expected to call #{Fields}.create_from_data(data: entry_hash, xmlns: xmlns_hash)" do
            allow(Fields).to receive(:create_from_data).and_call_original
            allow(page.entries).to receive(:each).and_call_original
            described_class.create_from_page page
            expect(Fields).to have_received(:create_from_data)
          end

          it "is expected to call #{Entry}.new with Fields: created_fields" do
            allow(Entry).to receive(:new).and_call_original
            described_class.create_from_page page
            expect(Entry).to have_received(:new)
          end

          it "is expected to add the new entry to the new entries" do
            e = Entries.new
            allow(Entries).to receive(:new).and_return(e)
            allow(e).to receive(:add).and_call_original
            described_class.create_from_page page
            expect(e).to have_received(:add)
          end

          it "is expected to return the new entries" do
            e = Entries.new
            allow(Entries).to receive(:new).and_return(e)
            expect(described_class.create_from_page(page)).to eq e
          end
        end
      end

      describe "Instance methods" do
        let(:entries) { described_class.new }
        let(:entry) { Entry.new }

        describe 'Signatures' do
          it { is_expected.to respond_to(:add).with(1).argument }
          it { is_expected.to respond_to(:each) }
          it { is_expected.to respond_to(:remove).with(1).argument }
          it { is_expected.to respond_to(:reset).with(0).arguments }
          it { is_expected.to respond_to(:[]).with(0..1).arguments }
        end

        # def [](key = nil)
        #   return @collection unless key
        #   result = @collection.find { |f| f.name == key }
        #   return result.value if result
        #   nil
        # end

        describe '::[] (addressable method)' do
          let(:id) { Parameters.account_id }

          before { entries.add entry }

          context "when no key is supplied" do
            it "is expected to return the entire collection" do
              expect(entries[]).to eq entries.collection
            end
          end

          context "when a value could not be found" do
            it "is expected to return nil" do
              expect(entries['aslkdj']).to eq nil
            end
          end

          it "is expected to return the value" do
            entry.id = id
            expect(entries[id]).to eq entry
          end
        end

        describe '::add' do
          context "when the provided argument is not a kind of #{Entry}" do
            it { expect { entries.add 1 }.to raise_argument_error(1, Entry) }
          end

          context 'when the provided entry is already in @collections' do
            before { entries.add entry }

            it { expect { entries.add entry }.not_to change(entries, :collection) }
          end

          it "is expected to add the argument to @collection" do
            expect { entries.add entry }.to change(entries, :collection).to([entry])
          end

          it "is expected to return self" do
            expect(entries.add(entry)).to eq entries
          end
        end

        describe '::each' do
          before { entries.add entry }

          specify { expect { |b| entries.each(&b) }.to yield_control.once }
        end

        describe '::reset' do
          before { entries.add entry }

          it { expect { entries.reset }.to change(entries, :collection).to([]) }
        end

        describe '::remove' do
          before { entries.add entry }

          context "when the provided field is not a kind of Field" do
            it { expect { entries.add 1 }.to raise_argument_error(1, Entry) }
          end

          it { expect { entries.remove entry }.to change(entries, :collection).to([]) }
        end
      end
    end
  end
end
