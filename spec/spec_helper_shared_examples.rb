include Cts::Mpx

RSpec.shared_examples 'registry_check' do |method|
  include_context "with web parameters"

  context "when the url is not availble locally" do
    before do
      allow(Registry).to receive(:fetch_and_store_domain).and_throw :yo
      allow(Services[post_parameters[:service]]).to receive(:url?).and_return nil
    end
    # reason: the first expect stops the execution after fetch_and_store_domain.    The second one assures it's called correctly.
    it "is expected to call Registry.fetch_and_store_domain with the user and account" do
      expect { described_class.send method, post_parameters }.to raise_error(UncaughtThrowError)
      expect(Registry).to have_received(:fetch_and_store_domain).with(user, nil)
    end
  end
end

RSpec.shared_examples "call_constraints" do
  it { expect { described_class.send method, post_parameters }.to raise_error_without_user_token(post_parameters[:user]) }
  it { is_expected.to require_keyword_arguments(method, post_parameters) }

  context "when headers is provided" do
    before { post_parameters[:headers] = { test: 1 } }

    it "is expected to pass them to Request.call" do
      allow(Driver::Request).to receive(:create).and_call_original
      described_class.send method, post_parameters
      expect(Driver::Request).to have_received(:create).with(a_hash_including(headers: { test: 1 }))
    end
  end

  context "when the url is not availble locally" do
    before do
      allow(Registry).to receive(:fetch_and_store_domain).and_throw :yo
      allow(Services[post_parameters[:service]]).to receive(:url?).and_return nil
    end
    # reason: the first expect stops the execution after fetch_and_store_domain.    The second one assures it's called correctly.
    it "is expected to call Registry.fetch_and_store_domain with the user and account" do
      expect { described_class.send(method, post_parameters) }.to raise_error(UncaughtThrowError)
      expect(Registry).to have_received(:fetch_and_store_domain).with(user, nil)
    end
  end

  include_examples 'call_assembler', :host, %i[user service]
  include_examples 'call_assembler', :path, %i[service endpoint]
  include_examples 'call_assembler', :query, %i[user service endpoint query]
end

RSpec.shared_examples "call_assembler" do |method, param_list|
  it "is expected to call Driver::Assemblers.#{method} with #{param_list.join(', ')}" do
    allow(Driver::Assemblers).to receive(method).and_call_original
    described_class.send method, post_parameters
    param_hash = {}
    param_list.each { |param| param_hash[param] = post_parameters[param] }
    expect(Driver::Assemblers).to have_received(method).with(a_hash_including(param_hash))
  end
end

RSpec.shared_examples "call_request" do |method|
  it "is expected to call Request.create with #{method.upcase} with '...'" do
    allow(Driver::Request).to receive(:create).and_call_original
    described_class.send method, post_parameters
    expect(Driver::Request).to have_received(:create)
  end

  it "is expected to return a response.data" do
    described_class.send method, post_parameters
    expect(request).to have_received(:call)
  end
end

RSpec.shared_examples "when the user is not logged in" do |method|
  context "when the user is not logged in" do
    before { user.instance_variable_set :@token, nil }

    it { expect { Services::Data.send method.to_sym, call_params }.to raise_error_without_user_token }
  end
end

RSpec.shared_examples "when a required keyword isn't set" do
  context "when a required keyword isn't set" do
    metadata[:required_keywords].each do |keyword|
      it "#{keyword} is expected to raise a specific message" do
        call_params.delete keyword
        expect(Services::Data.send(described_class, call_params)).to require_keyword_arguments call_parent, described_class, call_params
      end
    end
  end
end

RSpec.shared_examples "when a keyword is not a type of" do |method|
  metadata[:keyword_types].each do |k, v|
    context "when #{k} is not a type of #{v}" do
      before { call_params[k] = '' }

      it { expect { Services::Data.send method, call_params }.to raise_argument_exception call_params[k], v }
    end
  end
end
