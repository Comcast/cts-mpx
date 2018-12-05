# Examples

## Preamble

``` ruby
username = 'a_user@somewhere.com'
password = 'jghajg84j1mca'
account = 'http://access.auth.theplatform.com/data/Account/1'
```

## User Class

### Login

``` ruby
user = Cts::Mpx::User.create(username: ENV["MPX_USERNAME"], password: ENV["MPX_PASSWORD"]).sign_in
```

### Logout

``` ruby
user.sign_out
```

## Web.post

```ruby
response = Services::Web.post user: user, service: 'File Management Service', endpoint: 'FileManagement', method: 'resetTask', arguments: {"taskId": "http://..."}
puts response.status
```

## Ingest.post

## Rest Methods (Data endpoint)

### GET

``` ruby
response = Cts::Mpx::Services::Data.get user: user, service:  'Media Data Service', endpoint: 'Media', account: account, fields: 'id,guid'
puts response.page.entries
```

### POST

``` ruby
Cts::Mpx::Services::Data.post user: user, service:  'Media Data Service', endpoint: 'Media', account: account, page: Page.create(entries:[{"id": "http://data.media.theplatform.com/data/media/1"}])
```

### PUT

``` ruby
Cts::Mpx::Services::Data.put user: user, service:  'Media Data Service', endpoint: 'Media', account: account, page: Page.create(entries:[{}])
```

### DELETE

``` ruby
response = Cts::Mpx::Services::Data.delete user: user, service:  'Media Data Service', endpoint: 'Media', account: account, fields: 'id,guid', ids: "1,2,3,4"
puts response.page.entries
```

## Page class

### Create

``` ruby
page = Page.create(xmlns: {namespace: 'http://...'}, entries: [{}])
```

### output

``` ruby
puts page.to_s
```

### Indented Output

``` ruby
puts page.to_s(true)
```

## Query

``` ruby
media_query = Query.create({
  account_id:  "http://access.auth.theplatform.com/data/Account/2034777617",
  service:  'Media Data Service',
  endpoint: 'Media',
  fields:    'id,guid,title,ownerId'
}).run user: user

media_query.entries
```
