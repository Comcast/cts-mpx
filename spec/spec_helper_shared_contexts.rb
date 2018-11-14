require 'rspec'

RSpec.shared_context "with basic parameters" do
  let(:account_id) { "http://access.auth.theplatform.com/data/Account/1" }
  let(:entries) { Cts::Mpx::Entries.create collection: [media_entry] }
  let(:media_endpoint) { 'Media' }
  let(:media_entry) { Cts::Mpx::Entry.create(id: media_id) {|e| e.id = e.fields['id']} }
  let(:media_id) { 'http://data.media.theplatform.com/media/data/Media/1' }
  let(:media_service) { 'Media Data Service' }
  let(:root_account_id) { 'urn:theplatform:auth:root' }
end

RSpec.shared_context "with authentication parameters" do
  let(:parameters) { { user: user, service: 'User Data Service', endpoint: 'Authentication', method: 'signIn', arguments: {}, headers: { "Authorization"=>"Basic YTpi" } } }
  let(:parameters) { { user: user, service: 'User Data Service', endpoint: 'Authentication', method: 'signOut', arguments: { "token" => token } } }
end

RSpec.shared_context "with web parameters" do
  # let(:excon_response_hash) { { "signOutResponse" => {} } }
  let(:parameters) { { service: Parameters.web_service, endpoint: Parameters.web_endpoint, method: Parameters.web_method, arguments: Parameters.web_arguments } }
end

RSpec.shared_context "with user" do
  let(:user) { Cts::Mpx::User.create username: user_name, password: user_password, token: user_token }
  let(:user_name) { "no-reply@comcast.net" }
  let(:user_password) { "a_password" }
  let(:user_token) { "carpe diem" }
end

RSpec.shared_context "with field and fields" do
  let(:field) { Cts::Mpx::Field.create name: field_name, value: field_value }
  let(:field_name) { 'guid' }
  let(:field_value) { 'carpe diem' }
  let(:custom_field) { Cts::Mpx::Field.create name: custom_field_name, value: custom_field_value , xmlns: custom_field_xmlns }
  let(:custom_field_value) { 'a_custom_field_value' }
  let(:custom_field_name) { 'custom$guid' }
  let(:custom_field_xmlns) { { 'custom' => 'uuid' } }
end

RSpec.shared_context "with excon driver" do
  let(:excon_body) { Oj.dump(excon_response_hash) }
  let(:excon_headers) { {} }
  let(:excon_response) { Excon::Response.new body: excon_body, headers: excon_headers, status: excon_status }
  let(:excon_status) { 200 }
  let(:excon_response_hash) { { "xmlns" => {}, "entries" => []}}
  let(:populated_excon_body) { Oj.dump(populated_excon_response_hash) }
  let(:populated_excon_response) { Excon::Response.new body: populated_excon_body, headers: excon_headers, status: excon_status }
  let(:populated_excon_response_hash) { { "xmlns" => {}, "entries" => [ "id" => media_id]}}
  let(:page) { Cts::Mpx::Driver::Page.create page_parameters }
  let(:page_parameters) { { "entries" => [], "xmlns" => {} } }
  let(:page_populated) { Cts::Mpx::Driver::Page.create populated_page_parameters }
  let(:page_popluated_parameters) { { xmlns: xmlns, entries: entries } }
end

RSpec.shared_context "with request and response" do
  include_context "with excon driver"
  let(:request) { Cts::Mpx::Driver::Request.create method: :get, url: "http://access.auth.theplatform.com/data/Account/1" }
  let(:response) { Cts::Mpx::Driver::Response.create original: excon_response }
  let(:populated_response) { Cts::Mpx::Driver::Response.create original: populated_excon_response }
end
