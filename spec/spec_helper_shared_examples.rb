include Cts::Mpx

RSpec.shared_examples 'registry_check' do |method|
  include_context "with web parameters"

  context "when the url is not availble locally" do
    before do
      allow(Registry).to receive(:fetch_and_store_domain).and_throw :yo
      allow(Services[call_params[:service]]).to receive(:url?).and_return nil
    end

    # rubocop: disable RSpec/MultipleExpectations
    # reason, sometimes it just has to go down like that.
    it "is expected to call Registry.fetch_and_store_domain with the user and account" do
      expect { described_class.send method, call_params }.to raise_error(UncaughtThrowError)
      expect(Registry).to have_received(:fetch_and_store_domain).with(user, nil)
    end
    # rubocop: enable RSpec/MultipleExpectations
  end
end

RSpec.shared_examples "when the user is not logged in" do
  context "when the user is not logged in" do
    before { user.instance_variable_set :@token, nil }

    it { expect { parent_class.send described_class.to_sym, call_params }.to raise_error_without_user_token }
  end
end

RSpec.shared_examples "when a keyword is not a type of" do |method|
  metadata[:keyword_types].each do |keyword, value|
    context "when #{keyword} is not a type of #{value}" do
      before do
        allow(Driver::Exceptions).to receive(:raise_unless_required_keyword?).and_return nil
        call_params[keyword] = if keyword.is_a? String
                                 nil
                               else
                                 ''
                               end
      end

      it { expect { parent_class.send method, call_params }.to raise_argument_exception call_params[keyword], value }
    end
  end
end

# metadata[:required_keywords] is an array of symbols
# let(:parent_class) { Module or currently described class (Data, Assemblers)}
# let(:described_class) { method in symbol form (:put, :post)}
# let(:call_params) { parameters to pass to the send call}
RSpec.shared_examples "when a required keyword isn't set" do
  metadata[:required_keywords].each do |keyword|
    context "when a #{keyword} is not provided" do
      before { call_params[keyword] = nil }

      it { expect { parent_class.send(described_class, call_params) }.to raise_exception_without_required keyword }
    end
  end
end
