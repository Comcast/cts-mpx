require 'rspec'

RSpec.shared_context "with basic parameters" do
  let(:account_id) { "http://access.auth.theplatform.com/data/Account/1" }
  let(:root_account_id) { 'urn:theplatform:auth:root' }
end

RSpec.shared_context "with basic objects" do
  let(:entry) { Cts::Mpx::Entry.new }
  let(:query) { Cts::Mpx::Query.new }
  let(:fields) { Cts::Mpx::Fields.new }
end

RSpec.shared_context "with media entry" do
  include_context "with basic objects"
  let(:media_endpoint) { 'Media' }
  let(:media_entry) { Cts::Mpx::Entry.create(id: media_id) { |object| object.id = object.id } }
  let(:media_id) { 'http://data.media.theplatform.com/media/data/Media/1' }
  let(:media_service) { 'Media Data Service' }
end

RSpec.shared_context "with media entries" do
  include_context "with media entry"
  let(:media_entries) { Cts::Mpx::Entries.create collection: [media_entry] }
end

RSpec.shared_context "with authentication parameters" do
  let(:parameters) { { user: user, service: 'User Data Service', endpoint: 'Authentication', method: 'signIn', arguments: {}, headers: { "Authorization"=>"Basic YTpi" } } }
  let(:parameters) { { user: user, service: 'User Data Service', endpoint: 'Authentication', method: 'signOut', arguments: { "token" => token } } }
end

RSpec.shared_context "with web parameters" do
  include_context "with user"

  let(:web_arguments) { { 'username' => user_name, 'password' => user_password } }
  let(:web_endpoint) { 'Authentication' }
  let(:web_method) { 'signIn' }
  let(:web_assembler_parameters) { { service: web_service, endpoint: web_endpoint, method: web_method, arguments: web_arguments } }
  let(:web_post_parameters) { web_assembler_parameters.merge(user: user, query: {}) }
  let(:web_payload) { {} }
  let(:web_service) { 'User Data Service' }
end

RSpec.shared_context "with user" do
  let(:user) { Cts::Mpx::User.create username: user_name, password: user_password, token: user_token }
  let(:user_name) { "no-reply@comcast.net" }
  let(:user_password) { "a_password" }
  let(:user_token) { "carpe diem" }
end

RSpec.shared_context "with field" do
  let(:field) { Cts::Mpx::Field.create name: field_name, value: field_value }
  let(:field_name) { 'guid' }
  let(:field_value) { 'carpe diem' }
  let(:custom_field) { Cts::Mpx::Field.create name: custom_field_name, value: custom_field_value , xmlns: custom_field_xmlns }
  let(:custom_field_value) { 'a_custom_field_value' }
  let(:custom_field_name) { 'custom$guid' }
  let(:custom_field_xmlns) { { 'custom' => 'uuid' } }
end

RSpec.shared_context "with fields" do
  include_context "with field"
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
  let(:headers) do
    { "Access-Control-Allow-Origin" => "*",
      "X-Cache"                     => "MISS from data.media.theplatform.com:80",
      "Cache-Control"               => "max-age=0",
      "Date"                        => "Tue, 15 May 2018 00:25:24 GMT",
      "Content-Type"                => "application/json; charset=UTF-8",
      "Content-Length"              => "2050",
      "Server"                      => "Jetty(8.1.16.2)" }
  end
  let(:service_exception) do
    {
      "title"            => "ObjectNotFoundException",
      "description"      => "Could not find object with ID q",
      "isException"      => true,
      "responseCode"     => 404,
      "correlationId"    => "9a23ea0a-0975-4633-9af0-5f7fe3e83f2b",
      "serverStackTrace" => "com.theplatform.data.api.exception.ObjectNotFoundException: ..."
    }
  end
end

RSpec.shared_context "with page" do
  include_context "with excon driver"
  include_context "with media entries"
  let(:page) { Cts::Mpx::Driver::Page.create page_parameters }
  let(:page_parameters) { { xmlns: {}, entries: {} } }
  let(:populated_page) { Cts::Mpx::Driver::Page.create populated_page_parameters }
  let(:populated_page_parameters) { media_entries.to_h }
end

RSpec.shared_context "with request and response" do
  include_context "with excon driver"
  let(:request) { Cts::Mpx::Driver::Request.create method: :get, url: "http://access.auth.theplatform.com/data/Account/1" }
  let(:response) { Cts::Mpx::Driver::Response.create original: excon_response }
  let(:populated_response) { Cts::Mpx::Driver::Response.create original: populated_excon_response }
end
