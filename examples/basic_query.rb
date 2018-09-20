require 'cts/mpx'

user = Cts::Mpx::User.create(username: 'username', password: '*****').sign_in
account = "http://access.auth.theplatform.com/data/Account/0000000000"
service = 'Media Data Service'
endpoint = 'Media'

# build our query, and immediately run it.
q = Query.create(account: account, service: service, endpoint: endpoint, fields: 'id,guid,title').run user: user

### Print out a single entry
puts q.entries.first.to_h

### Print out just the intries
puts q.entries.to_h

### Print out the query (including entries)
puts q.entries.to_h

### Print out the query (without entries)
puts q.entries.to_h include_entries: false

user.sign_out
