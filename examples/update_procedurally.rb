require 'cts/mpx'

user = Cts::Mpx::User.create(username: 'username', password: '*****').sign_in
account = "http://access.auth.theplatform.com/data/Account/0000000000"
service = 'Media Data Service'
endpoint = 'Media'

response = Cts::Mpx::Services::Data.get user: user, service: service, endpoint: endpoint, account: account, fields: 'id,guid,title,description'
media = response.page

# modify them all
media.entries.each { |e| e["description"] = '1' }

# put them back
response = Cts::Mpx::Services::Data.put user: user, service: 'Media Data Service', endpoint: endpoint, account: account, page: media

# show response
puts response.status

user.sign_out
