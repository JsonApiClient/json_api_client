# JsonApiClient [![Build Status](https://travis-ci.org/chingor13/json_api_client.png)](https://travis-ci.org/chingor13/json_api_client) [![Code Climate](https://codeclimate.com/github/chingor13/json_api_client.png)](https://codeclimate.com/github/chingor13/json_api_client) [![Code Coverage](https://codeclimate.com/github/chingor13/json_api_client/coverage.png)](https://codeclimate.com/github/chingor13/json_api_client)

This gem is meant to help you build an API client for interacting with REST APIs as laid out by [http://jsonapi.org](http://jsonapi.org). It attempts to give you a query building framework that is easy to understand (it is similar to ActiveRecord scopes).

*Note: master is currently tracking the 1.0.0 RC3 specification. If you're looking for the older code, see [0.x branch](https://github.com/chingor13/json_api_client/tree/0.x)*

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

You can configure your API client to use a custom connection that implementes the `run` instance method. It should return data that your parser can handle.

```
class NullConnection
  def initialize(*args)
  end

  def run(request_method, path, params = {}, headers = {})
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

Out of the box, `json_api_client` handles server side validation only.

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

If you want to add client side validation, I suggest creating a form model class that uses ActiveModel's validations.

## Nested Resources

You can force nested resource paths for your models by using a `belongs_to` association.

```
module MyApi
  class Account < JsonApiClient::Resource
  	belongs_to :user
  end
end

# try to find without the nested parameter
MyApi::Account.find(1)
=> raises ArgumentError

# makes request to /users/2/accounts/1
MyApi::Account.where(user_id: 2).find(1)
=> returns ResultSet
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

# makes GET request to /users/search?name=Jeff
MyApi::User.search(name: 'Jeff')
=> <ResultSet of MyApi::User instances>

user = MyApi::User.find(1)
# makes PUT request to /users/1/verify?foo=bar
user.verify(foo: 'bar')
```

## Fetching Includes

[See specification](http://jsonapi.org/format/#fetching-includes)

If the response returns a [compound document](http://jsonapi.org/format/#document-structure-compound-documents), then we should be able to get the related resources.

```
# makes request to /articles/1?include=author,comments.author
results = Article.includes(:author, :comments => :author).find(1)

# should not have to make additional requests to the server
authors = results.map(&:author)
```

## Sparse Fieldsets

[See specification](http://jsonapi.org/format/#fetching-sparse-fieldsets)

```
# makes request to /articles?fields[articles]=title,body
article = Article.select("title,body").first

# should have fetched the requested fields
article.title
=> "Rails is Omakase"

# should not have returned the created_at
article.created_at
=> raise NoMethodError
```

## Sorting

[See specification](http://jsonapi.org/format/#fetching-sorting)

```
# makes request to /people?sort=+age
youngest = Person.sort(:age).all

# also makes request to /people?sort=+age
youngest = Person.sort(age: :asc).all

# makes request to /people?sort=-age
oldest = Person.sort(age: :desc).all
```

## Paginating

[See specification](http://jsonapi.org/format/#fetching-pagination)

```
# makes request to /articles?page=2&per_page=30
articles = Article.page(2).per(30).to_a

# also makes request to /articles?page=2&per_page=30
articles = Article.paginate(page: 2, per_page: 30).to_a
```

*Note: The mapping of pagination parameter is done by the `query_builder` which is [customizable](#fixme).*

## Filtering

[See specifiation](http://jsonapi.org/format/#fetching-filtering)

```
# makes request to /people?filter[name]=Jeff
Person.where(name: 'Jeff').all
```

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

## Customizing