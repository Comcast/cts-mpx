require 'cts/mpx'

user = Cts::Mpx::User.create(username: 'username', password: '*****').sign_in
account = "http://access.auth.theplatform.com/data/Account/0000000000"
service = 'Media Data Service'
endpoint = 'Media'

# build our query, and immediately run it.
q = Query.create(account: account, service: service, endpoint: endpoint, fields: 'id,guid,title').run user: user

q.entries.each do |entry|
  entry.title += '!!!'
  entry.save
end

user.sign_out
