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

You can configure your connection using Faraday middleware. In general, you'll want 
to do this in a base model that all your resources inherit from:

```
MyApi::Base.connection do |connection|
  # set OAuth2 headers
  connection.use Faraday::Request::Oauth2, 'MYTOKEN'

  # log responses
  connection.use Faraday::Response::Logger

  connection.use MyCustomMiddleware
end

module MyApi
  class User < Base
    # will use the customized connection
  end
end
```

## Custom Parser

You can configure your API client to use a custom parser that implements the `parse` class method.  It should return a `JsonApiClient::ResultSet` instance. You can use it by setting the parser attribute on your model:

```
class MyCustomParser
  def self.parse(klass, response)
  	…
  	# returns some ResultSet object
  end
end

class MyApi::Base < JsonApiClient::Resource
  self.parser = MyCustomParser
end
```

## Handling Validation Errors

```
User.create(name: "Bob", email_address: "invalid email")
=> false

user = User.new(name: "Bob", email_address: "invalid email")
user.save
=> false
user.errors
=> ["Email address is invalid"]

user = User.find(1)
user.update_attributes(email_address: "invalid email")
=> false
user.errors
=> ["Email address is invalid"]
user.email_address
=> "invalid email"

```