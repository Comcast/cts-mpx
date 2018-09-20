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
user = Cts::Mpx::User.create username: username, password: password
user.sign_in
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
puts response.page
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
puts response.page
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