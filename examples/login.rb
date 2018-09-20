require 'cts/mpx'

### You can split the sign_in into it's own line.
user = Cts::Mpx::User.create(username: 'username', password: '*****').sign_in

### begone token!
user.sign_out
