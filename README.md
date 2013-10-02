# JsonApiClient

## Usage

```
module MyApi
  class User < JsonApiClient::Resource
  end
end

MyApi::User.all
MyApi::User.where(account_id: 1).find(1)
MyApi::User.where(account_id: 1).all

MyApi::User.where(name: "foo").order("created_at desc").includes(:preferences, :cars).all

u = MyApi::User.new(foo: "bar", bar: "foo")
u.save

u = MyApi::User.find(1)
u.update_attributes(
  a: "b",
  c: "d"
)

u = MyApi::User.create(
  a: "b",
  c: "d"
)

u = MyApi::User.find(1)
u.accounts
=> MyApi::Account.where(user_id: u.id).all
```

## Connection options

You can configure your connection using Faraday middleware:

```
MyApi::Account.connection do |connection|
  # set OAuth2 headers
  connection.request :oauth2, 'MYTOKEN'

  # log responses
  connection.response :logger

  connection.use MyCustomMiddleware
end
```