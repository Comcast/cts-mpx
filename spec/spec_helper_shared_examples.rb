module RSpec
  include Cts::Mpx

  shared_examples 'registry_check' do |method|
    context "when the url is not availble locally" do
      before do
        allow(Registry).to receive(:fetch_and_store_domain).and_throw :yo
        allow(Services[call_params[:service]]).to receive(:url?).and_return nil
      end

      # rubocop: disable RSpec/MultipleExpectations
      # reason: the first expect stops the execution after fetch_and_store_domain.    The second one assures it's called correctly.
      it "is expected to call Registry.fetch_and_store_domain with the user and account" do
        expect { described_class.send method, call_params }.to raise_error(UncaughtThrowError)
        expect(Registry).to have_received(:fetch_and_store_domain).with(user, nil)
      end
      # rubocop: enable RSpec/MultipleExpectations
    end
  end

  shared_examples "call_constraints" do
    it { expect { described_class.send call_method, call_params }.to raise_error_without_user_token(call_params[:user]) }
    it { is_expected.to require_keyword_arguments(call_method, call_params) }

    context "when headers is provided" do
      before { call_params[:headers] = { test: 1 } }

      it "is expected to pass them to Request.call" do
        allow(Driver::Request).to receive(:create).and_call_original
        described_class.send call_method, call_params
        expect(Driver::Request).to have_received(:create).with(a_hash_including(headers: { test: 1 }))
      end
    end

    context "when the url is not availble locally" do
      before do
        allow(Registry).to receive(:fetch_and_store_domain).and_throw :yo
        allow(Services[call_params[:service]]).to receive(:url?).and_return nil
      end

      # rubocop: disable RSpec/MultipleExpectations
      # reason: the first expect stops the execution after fetch_and_store_domain.    The second one assures it's called correctly.
      it "is expected to call Registry.fetch_and_store_domain with the user and account" do
        expect { described_class.send(call_method, call_params) }.to raise_error(UncaughtThrowError)
        expect(Registry).to have_received(:fetch_and_store_domain).with(user, nil)
      end
      # rubocop: enable RSpec/MultipleExpectations
    end

    include_examples 'call_assembler', :host, %i[user service]
    include_examples 'call_assembler', :path, %i[service endpoint]
    include_examples 'call_assembler', :query, %i[user service endpoint query]
  end

  shared_examples "call_assembler" do |method, param_list|
    it "is expected to call Driver::Assemblers.#{method} with #{param_list.join(', ')}" do
      allow(Driver::Assemblers).to receive(method).and_call_original
      described_class.send call_method, call_params
      expect(Driver::Assemblers).to have_received(method).with(a_hash_including(param_list.map { |i| [i, call_params[i]] }.to_h))
    end
  end

  shared_examples "call_request" do |method|
    it "is expected to call Request.create with #{method.upcase} with '...'" do
      allow(Driver::Request).to receive(:create).and_call_original
      described_class.send method, call_params
      expect(Driver::Request).to have_received(:create)
    end

    it "is expected to return a response.data" do
      described_class.send call_method, call_params
      expect(request).to have_received(:call)
    end
  end
end
