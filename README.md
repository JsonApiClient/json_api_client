# JsonApiClient [![Build Status](https://travis-ci.org/chingor13/json_api_client.png)](https://travis-ci.org/chingor13/json_api_client) [![Code Climate](https://codeclimate.com/github/chingor13/json_api_client.png)](https://codeclimate.com/github/chingor13/json_api_client) [![Code Coverage](https://codeclimate.com/github/chingor13/json_api_client/coverage.png)](https://codeclimate.com/github/chingor13/json_api_client)

This gem is meant to help you build an API client for interacting with REST APIs as laid out by [http://jsonapi.org](http://jsonapi.org). It attempts to give you a query building framework that is easy to understand (it is similar to ActiveRecord scopes).

*Note: master is currently tracking the 1.0.0 RC3 specification. If you're looking for the older code, see [0.x branch](https://github.com/chingor13/json_api_client/tree/0.x)*

*Note: This is still a work in progress.*

## Usage

You will want to create your own resource classes that inherit from `JsonApiClient::Resource` similar to how you would create an `ActiveRecord` class. You may also want to create your own abstract base class to share common behavior. Additionally, you will probably want to namespace your models. Namespacing your model will not affect the url routing to that resource.

```
module MyApi
  # this is an "abstract" base class that 
  class Base < JsonApiClient::Resource
    # set the api base url in an abstract base class
    self.site = "http://example.com/"
  end

  class Article < Base
  end

  class Comment < Base
  end

  class Person < Base
  end
end
```

By convention, we figure guess the resource route from the class name. In the above example, `Article`'s path is "http://example.com/articles" and `Person`'s path would be "http://example.com/people".

Some example usage:

```
MyApi::Article.all
MyApi::Article.where(author_id: 1).find(2)
MyApi::Article.where(author_id: 1).all

MyApi::Person.where(name: "foo").order(created_at: :desc).includes(:preferences, :cars).all

u = MyApi::Person.new(first_name: "bar", last_name: "foo")
u.save

u = MyApi::Person.find(1).first
u.update_attributes(
  a: "b",
  c: "d"
)

u = MyApi::Person.create(
  a: "b",
  c: "d"
)
```

All class level finders/creators should return a `JsonApiClient::ResultSet` which behaves like an Array and contains extra data about the api response.


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

## Meta information

[See specification](http://jsonapi.org/format/#document-structure-meta)

If the response has a top level meta data section, we can access it via the `meta` accessor on `ResultSet`.

```
# Example response:
{
  "meta": {
    "copyright": "Copyright 2015 Example Corp.",
    "authors": [
      "Yehuda Katz",
      "Steve Klabnik",
      "Dan Gebhardt"
    ]
  },
  "data": {
    // ...
  }
}
articles = Articles.all

articles.meta.copyright
=> "Copyright 2015 Example Corp."
articles.meta.authors
=> ["Yehuda Katz", "Steve Klabnik", "Dan Gebhardt"]
```

## Top-level Links

[See specification](http://jsonapi.org/format/#document-structure-top-level-links)

If the resource returns top level links, we can access them via the `links` accessor on `ResultSet`.

```
articles = Articles.find(1)
articles.links.related
```

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

### Requesting

```
# makes request to /articles?page=2&per_page=30
articles = Article.page(2).per(30).to_a

# also makes request to /articles?page=2&per_page=30
articles = Article.paginate(page: 2, per_page: 30).to_a
```

*Note: The mapping of pagination parameters is done by the `query_builder` which is [customizable](#fixme).*

### Browsing

If the response contains additional pagination links, you can also get at those:

```
articles = Article.paginate(page: 2, per_page: 30).to_a
articles.pages.next
articles.pages.last
```

### Library compatibility

A `JsonApiClient::ResultSet` object should be paginatable with both `kaminari` and `will_paginate`.

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
* `:time` - *Note: Include the time zone in the string if it's different than local time.
* `:boolean` - *Note: we will cast the string version of "true" and "false" to their respective values*

Also, we consider `nil` to be an acceptable value and will not cast the value.

## Customizing

### Connections

You can configure your API client to use a custom connection that implementes the `run` instance method. It should return data that your parser can handle. The default connection class wraps Faraday and lets you add middleware.

```
class NullConnection
  def initialize(*args)
  end

  def run(request_method, path, params = {}, headers = {})
  end

  def use(*args); end
end

class CustomConnectionResource < TestResource
  self.connection_class = NullConnection
end

```

#### Connection Options

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

### Custom Parser

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

### Custom Query Builder

You can customize how the scope builder methods map to request parameters.

```
class MyQueryBuilder
  def def initialize(klass); end

  def where(conditions = {})
  end

  … add order, includes, paginate, page, first, build
end

class MyApi::Base < JsonApiClient::Resource
  self.query_builder = MyQueryBuilder
end
```

### Custom Paginator

You can customize how your resources find pagination information from the response.

```
class MyPaginator
  def initialize(result_set, data); end
  # implement current_page, total_entries, etc
end

class MyApi::Base < JsonApiClient::Resource
  self.paginator = MyPaginator
end
```
