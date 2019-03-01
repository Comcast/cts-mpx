require 'spec_helper'

describe Cts::Mpx::Services::Data do
  let(:params) do
    {
      endpoint: 'Media',
      fields:   'id,guid',
      headers:  {},
      service:  'Media Data Service',
      query:    {},
      user:     Cts::Mpx::User.create(username: 'a', password: 'b', token: 't')
    }
  end
  let(:request) { Driver::Request.new }

  before do
    allow(Driver::Request).to receive(:create).and_return(request)
    allow(request).to receive(:call).and_return(Driver::Response.new)
    allow(Registry).to receive(:fetch_and_store_domain)
    allow(described_class).to receive(:constraints!).and_return nil
  end

  it { is_expected.to respond_to(:[]).with(0..1).arguments }
  it { is_expected.to respond_to(:delete).with_keywords(:user, :account_id, :service, :endpoint, :sort, :extra_path, :range, :ids, :query, :headers, :count, :entries) }
  it { is_expected.to respond_to(:get).with_keywords(:user, :account_id, :service, :endpoint, :sort, :extra_path, :range, :ids, :query, :headers, :count, :entries, :fields) }
  it { is_expected.to respond_to(:post).with_keywords(:user, :account_id, :service, :endpoint, :extra_path, :query, :page, :headers) }
  it { is_expected.to respond_to(:put).with_keywords(:user, :account_id, :service, :endpoint, :extra_path, :query, :page, :headers) }

  shared_examples "registry_fetch_and_store_domain" do
    describe Registry.to_s do
      it { expect(Registry).to have_received(:fetch_and_store_domain) }
    end
  end

  shared_examples "Driver::Request" do
    describe "Driver::Request (with a media endpoint)" do
      it { expect(Driver::Request).to have_received(:create).with(a_hash_including(:url, :query, :method, :headers)) }
      it { expect(Driver::Request).to have_received(:create).with(a_hash_including(url: a_string_including('media/data/Media'))) }
      it { expect(request).to have_received(:call).with(no_args) }
    end
  end

  shared_examples "when_x_is_not_a_y" do |x,y|
    context "when #{x} is not a #{y}" do
      before { params[x] = 'a_string' }

      it { is_expected.to raise_error ArgumentError, /a_string is not a valid #{y}/ }
    end
  end

  describe "::[] (addressable method)" do
    let(:service) { 'Media Data Service' }

    it "is expected to search for services that are type: data only" do
      expect(described_class[].count).to eq 29
    end

    it { expect(described_class[service]).to be_instance_of Driver::Service }

    context "when the key is not a string" do
      it { expect { described_class[1] }.to raise_error(ArgumentError, /key must be a string/) }
    end

    context "when the key is not a service name" do
      it { expect { described_class['1'] }.to raise_error(ArgumentError, /must be a service name/) }
    end

    context "when a key is not provided" do
      it { expect(described_class[]).to be_instance_of Array }
    end
  end

  describe '.get' do
    let(:subject) { proc { described_class.get(params) } }

    before do
      subject.call
    end

    it { expect(described_class).to have_received(:constraints!) }
    it { result_is_expected.to return_a_kind_of Driver::Response }

    include_examples "registry_fetch_and_store_domain"
    include_examples "Driver::Request"

    context "when the fields keyword is provided, Driver::Request" do
      it { expect(Driver::Request).to have_received(:create).with(a_hash_including(query: a_hash_including(:fields))) }
    end
  end

  describe ".constraints!" do
    let(:subject) { proc { described_class.constraints!(params) } }

    before { allow(described_class).to receive(:constraints!).and_call_original }

    include_examples "when_x_is_not_a_y", :query, Hash
    include_examples "when_x_is_not_a_y", :headers, Hash
    include_examples "when_x_is_not_a_y", :page, Cts::Mpx::Driver::Page

    context "when the user is not logged in" do
      let(:params) { { user: User.create(username: 'a', password: 'b') } }

      it { is_expected.to raise_error_without_user_token(params[:user]) }
    end

    context "when a required argument is missing (a_keyword)" do
      let(:params) { { required_keywords: [:a_keyword] } }

      it { is_expected.to raise_error ArgumentError, /a_keyword is a required keyword/ }
    end
  end
end
