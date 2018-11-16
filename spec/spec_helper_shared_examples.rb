module RSpec
  include Cts::Mpx

  shared_examples 'registry_check' do |method|
    context "when the url is not availble locally" do
      before do
        allow(Registry).to receive(:fetch_and_store_domain).and_throw :yo
        allow(Services[web_post_parameters[:service]]).to receive(:url?).and_return nil
      end

      # rubocop: disable RSpec/MultipleExpectations
      # reason: the first expect stops the execution after fetch_and_store_domain.    The second one assures it's called correctly.
      it "is expected to call Registry.fetch_and_store_domain with the user and account" do
        expect { described_class.send method, web_post_parameters }.to raise_error(UncaughtThrowError)
        expect(Registry).to have_received(:fetch_and_store_domain).with(user, nil)
      end
      # rubocop: enable RSpec/MultipleExpectations
    end
  end

  shared_examples "call_constraints" do
    it { expect { described_class.send call_method, web_post_parameters }.to raise_error_without_user_token(web_post_parameters[:user]) }
    it { is_expected.to require_keyword_arguments(call_method, web_post_parameters) }

    context "when headers is provided" do
      before { web_post_parameters[:headers] = { test: 1 } }

      it "is expected to pass them to Request.call" do
        allow(Driver::Request).to receive(:create).and_call_original
        described_class.send call_method, web_post_parameters
        expect(Driver::Request).to have_received(:create).with(a_hash_including(headers: { test: 1 }))
      end
    end

    context "when the url is not availble locally" do
      before do
        allow(Registry).to receive(:fetch_and_store_domain).and_throw :yo
        allow(Services[web_post_parameters[:service]]).to receive(:url?).and_return nil
      end

      # rubocop: disable RSpec/MultipleExpectations
      # reason: the first expect stops the execution after fetch_and_store_domain.    The second one assures it's called correctly.
      it "is expected to call Registry.fetch_and_store_domain with the user and account" do
        expect { described_class.send(call_method, web_post_parameters) }.to raise_error(UncaughtThrowError)
        expect(Registry).to have_received(:fetch_and_store_domain).with(user, nil)
      end
      # rubocop: enable RSpec/MultipleExpectations
    end

    include_examples 'call_assembler', :host, %i[user service]
    include_examples 'call_assembler', :path, %i[service endpoint]
    include_examples 'call_assembler', :query, %i[user service endpoint query]
  end

  shared_examples "call_assembler" do |method, param_list|
    include_context "with web parameters"

    it "is expected to call Driver::Assemblers.#{method} with #{param_list.join(', ')}" do
      allow(Driver::Assemblers).to receive(method).and_call_original
      described_class.send call_method, web_post_parameters
      param_hash = {}
      param_list.each { |param| param_hash[param] = web_post_parameters[param]}

      expect(Driver::Assemblers).to have_received(method).with(a_hash_including(param_hash))
    end
  end

  shared_examples "call_request" do |method|
    it "is expected to call Request.create with #{method.upcase} with '...'" do
      allow(Driver::Request).to receive(:create).and_call_original
      described_class.send method, web_post_parameters
      expect(Driver::Request).to have_received(:create)
    end

    it "is expected to return a response.data" do
      described_class.send call_method, web_post_parameters
      expect(request).to have_received(:call)
    end
  end
end
