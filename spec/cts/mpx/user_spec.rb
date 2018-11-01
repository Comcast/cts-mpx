require 'spec_helper'

module Cts
  module Mpx
    describe User do
      let(:user) { User.create username: 'a', password: 'b' }
      let(:token) { 'a_token' }

      it { is_expected.to be_a_kind_of Creatable }

      describe "Attributes" do
        it { is_expected.to have_attributes(username: nil) }
        it { is_expected.to have_attributes(password: nil) }
        it { is_expected.to have_attributes(idle_timeout: nil) }
        it { is_expected.to have_attributes(duration: nil) }
        it { is_expected.to have_attributes(token: nil) }
      end

      describe "Instance methods" do
        it { is_expected.to respond_to(:sign_out).with(0).arguments }
        it { is_expected.to respond_to(:token!).with(0).arguments }
        it { is_expected.to respond_to(:sign_in).with_keywords(:idle_timeout, :duration) }
      end

      describe "::inspect" do
        before { user.token = '1234' }

        context "when the password is set" do
          before { user.password = '1234' }

          it "is expected to not contain the password" do
            expect(user.inspect).not_to include('@password')
          end
        end

        it "returns a string with all set attributes" do
          expect(user.inspect).to include('@username').and include('@token')
        end
      end

      describe "::sign_in" do
        let(:idle_timeout) { 123 }
        let(:response_hash) do
          { "signInResponse" => { "token"       => "a_token",
                                  "duration"    => 315_360_000_000,
                                  "userName"    => "a_user@comcast.net",
                                  "userId"      => "https://identity.auth.theplatform.com/idm/data/User/mpx/1",
                                  "idleTimeout" => 14_400_000 } }
        end

        let(:excon_response) { Excon::Response.new body: Oj.dump(response_hash), status: 200 }
        let(:response) { Driver::Response.create(original: excon_response) }
        let(:duration) { 123 }
        let(:params) { { user: user, service: 'User Data Service', endpoint: 'Authentication', method: 'signIn', arguments: {}, headers: { "Authorization"=>"Basic YTpi" } } }

        before { allow(response).to receive(:healthy?).and_return true }

        context "when the token is already set" do
          before { user.token = 'a_real_token' }

          it "is expected to raise an exception with message /token is already set, use sign_out first./" do
            expect { user.sign_in }.to raise_error RuntimeError, /token is already set\, use sign_out first\./
          end
        end

        context "when status not equal to 200" do
          before { excon_response.status = 403 }

          it "is expected to raise an exception with sign_in exception and status code" do
            allow(Services::Web).to receive(:post).and_return response
            expect { user.sign_in }.to raise_error RuntimeError, /sign_in exception, status: /
          end
        end

        context "when duration is provided" do
          before { user.duration = duration }

          it "is expected to set duration" do
            allow(Services::Web).to receive(:post).and_return response
            user.sign_in
            expect(Services::Web).to have_received(:post).with params
          end
        end

        context "when idle_timeout is provided" do
          before { user.idle_timeout = idle_timeout }

          it "is expected to set idle_timeout" do
            allow(Services::Web).to receive(:post).and_return response
            user.sign_in
            expect(Services::Web).to have_received(:post).with params
          end
        end

        it "is expected to call Web.post with params" do
          allow(Services::Web).to receive(:post).and_return response
          user.sign_in
          expect(Services::Web).to have_received(:post).with params
        end

        it "is expected to set token to response.data['token']" do
          allow(Services::Web).to receive(:post).and_return response
          expect { user.sign_in }.to change(user, :token).to token
        end

        it "is expected to return self" do
          allow(Services::Web).to receive(:post).and_return response
          expect(user.sign_in).to eq user
        end
      end

      describe "::sign_out" do
        let(:excon_response) { Excon::Response.new body: '{"signOutResponse": {}}', status: 200 }
        let(:response) { Driver::Response.create(original: excon_response) }
        let(:params) { { user: user, service: 'User Data Service', endpoint: 'Authentication', method: 'signOut', arguments: { "token" => token } } }

        before do
          user.token = token
          allow(Services::Web).to receive(:post).and_return response
        end

        it "is expected to call Web.post with the token to sign out" do
          user.sign_out
          expect(Services::Web).to have_received(:post).with params
        end

        it "is expected to set token to nil" do
          user.sign_out
          expect(user.token).to be nil
        end

        it "is expected to return nil" do
          expect(user.sign_out).to be nil
        end
      end

      describe "::token!" do
        let(:user) { User.create username: 'a', password: 'b', token: 'token' }

        context "when the token is set to nil" do
          before { user.instance_variable_set :@token, nil }

          it "is expected to raise an exception" do
            expect { user.token! }.to raise_error RuntimeError, "#{user.username} is not signed in, (token is set to nil)."
          end
        end

        it "is expected to return the token" do
          expect(user.token!).to eq user.token
        end
      end
    end
  end
end
