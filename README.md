# JsonApiClient [![Build Status](https://travis-ci.org/chingor13/json_api_client.png)](https://travis-ci.org/chingor13/json_api_client) [![Code Climate](https://codeclimate.com/github/chingor13/json_api_client.png)](https://codeclimate.com/github/chingor13/json_api_client) [![Code Coverage](https://codeclimate.com/github/chingor13/json_api_client/coverage.png)](https://codeclimate.com/github/chingor13/json_api_client)

This gem is meant to help you build an API client for interacting with REST APIs as laid out by [http://jsonapi.org](http://jsonapi.org). It attempts to give you a query building framework that is easy to understand (it is similar to ActiveRecord scopes).

*Note: This is still a work in progress.*

## Usage

```
module MyApi
  class User < JsonApiClient::Resource
    has_many :accounts
  end

  class Account < JsonApiClient::Resource
  	belongs_to :user
  end
end

MyApi::User.all
MyApi::User.where(account_id: 1).find(1)
MyApi::User.where(account_id: 1).all

MyApi::User.where(name: "foo").order("created_at desc").includes(:preferences, :cars).all

u = MyApi::User.new(foo: "bar", bar: "foo")
u.save

u = MyApi::User.find(1).first
u.update_attributes(
  a: "b",
  c: "d"
)

u = MyApi::User.create(
  a: "b",
  c: "d"
)

u = MyApi::User.find(1).first
u.accounts
=> MyApi::Account.where(user_id: u.id).all
```

## Connection Options

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

## Custom Connection

You can configure your API client to use a custom connection that implementes the `execute` instance method. It should return data that your parser can handle.

```
class NullConnection
  def initialize(*args)
  end

  def execute(query)
  end
end

class CustomConnectionResource < TestResource
  self.connection_class = NullConnection
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

## Nested Resources

You can force nested resource paths for your models by using a `belongs_to` association.

```
module MyApi
  class Account < JsonApiClient::Resource
  	belongs_to :user
  end
end
```

## Custom Methods

You can create custom methods on both collections (class method) and members (instance methods).

```
module MyApi
  class User < JsonApiClient::Resource

  	# GET /users/search
  	custom_endpoint :search, on: :collection, request_method: :get

  	# PUT /users/:id/verify
  	custom_endpoint :verify, on: :member, request_method: :put
  end
end
```

In the above scenario, you can call the class method `MyApi::User.search`.  The results will be parsed like any other query.  If the response returns users, you will get back a `ResultSet` of `MyApi::User` instances.

You can also call the instance method `verify` on a `MyApi::User` instance.

## Links

We also respect the [links specification](http://jsonapi.org/format/#document-structure-resource-relationships). The client can fetch linked resources based on the defined endpoint from the link specification as well as load data from any `linked` data provided in the response. Additionally, it will still fetch missing data if not all linked resources are provided in the `linked` data response.

See the [tests](https://github.com/chingor13/json_api_client/blob/master/test/unit/links_test.rb).

## Schema

You can define schema within your client model. You can define basic types and set default values if you wish. If you declare a basic type, we will try to cast any input to be that type.

The added benefit of declaring your schema is that you can access fields before data is set (otherwise, you'll get a `NoMethodError`).

### Example

```
class User < JsonApiClient::Resource
  property :name, type: :string
  property :is_admin, type: :boolean, default: false
  property :points_accrued, type: :int, default: 0
  property :averge_points_per_day, type: :float
end

# default values
u = User.new
u.name
=> nil
u.is_admin
=> false
u.points_accrued
=> 0

# casting
u.average_points_per_day = "0.3"
u.average_points_per_day
=> 0.3

```

### Types

The basic types that we allow are:

* `:int` or `:integer`
* `:float`
* `:string`
* `:boolean` - *Note: we will cast the string version of "true" and "false" to their respective values*

Also, we consider `nil` to be an acceptable value and will not cast the value.
