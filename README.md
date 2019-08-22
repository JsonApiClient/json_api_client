# JsonApiClient [![Build Status](https://travis-ci.org/JsonApiClient/json_api_client.png)](https://travis-ci.org/JsonApiClient/json_api_client) [![Code Climate](https://codeclimate.com/github/JsonApiClient/json_api_client.png)](https://codeclimate.com/github/JsonApiClient/json_api_client) [![Code Coverage](https://codeclimate.com/github/JsonApiClient/json_api_client/coverage.png)](https://codeclimate.com/github/JsonApiClient/json_api_client)

This gem is meant to help you build an API client for interacting with REST APIs as laid out by [http://jsonapi.org](http://jsonapi.org). It attempts to give you a query building framework that is easy to understand (it is similar to ActiveRecord scopes).

*Note: master is currently tracking the 1.0.0 specification. If you're looking for the older code, see [0.x branch](https://github.com/JsonApiClient/json_api_client/tree/0.x)*

## Usage

You will want to create your own resource classes that inherit from `JsonApiClient::Resource` similar to how you would create an `ActiveRecord` class. You may also want to create your own abstract base class to share common behavior. Additionally, you will probably want to namespace your models. Namespacing your model will not affect the url routing to that resource.

```ruby
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

By convention, we guess the resource route from the class name. In the above example, `Article`'s path is "http://example.com/articles" and `Person`'s path would be "http://example.com/people".

Some basic example usage:

```ruby
MyApi::Article.all
MyApi::Article.where(author_id: 1).find(2)
MyApi::Article.where(author_id: 1).all

MyApi::Person.where(name: "foo").order(created_at: :desc).includes(:preferences, :cars).all

u = MyApi::Person.new(first_name: "bar", last_name: "foo")
u.new_record?
# => true
u.save

u.new_record?
# => false

u = MyApi::Person.find(1).first
u.update_attributes(
  a: "b",
  c: "d"
)

u.persisted?
# => true

u.destroy

u.destroyed?
# => true
u.persisted?
# => false

u = MyApi::Person.create(
  a: "b",
  c: "d"
)
```

All class level finders/creators should return a `JsonApiClient::ResultSet` which behaves like an Array and contains extra data about the api response.


## Handling Validation Errors

[See specification](http://jsonapi.org/format/#errors)

Out of the box, `json_api_client` handles server side validation only.

```ruby
User.create(name: "Bob", email_address: "invalid email")
# => false

user = User.new(name: "Bob", email_address: "invalid email")
user.save
# => false

# returns an error collector which is array-like
user.errors
# => ["Email address is invalid"]

# get all error titles
user.errors.full_messages
# => ["Email address is invalid"]

# get errors for a specific parameter
user.errors[:email_address]
# => ["Email address is invalid"]

user = User.find(1)
user.update_attributes(email_address: "invalid email")
# => false

user.errors
# => ["Email address is invalid"]

user.email_address
# => "invalid email"
```

For now we are assuming that error sources are all parameters.

If you want to add client side validation, I suggest creating a form model class that uses ActiveModel's validations.

## Meta information

[See specification](http://jsonapi.org/format/#document-structure-meta)

If the response has a top level meta data section, we can access it via the `meta` accessor on `ResultSet`.

```ruby
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
# => "Copyright 2015 Example Corp."

articles.meta.authors
# => ["Yehuda Katz", "Steve Klabnik", "Dan Gebhardt"]
```

## Top-level Links

[See specification](http://jsonapi.org/format/#document-structure-top-level-links)

If the resource returns top level links, we can access them via the `links` accessor on `ResultSet`.

```ruby
articles = Articles.find(1)
articles.links.related
```

## Nested Resources

You can force nested resource paths for your models by using a `belongs_to` association.

**Note: Using belongs_to is only necessary for setting a nested path unless you provide `shallow_path: true` option.**

```ruby
module MyApi
  class Account < JsonApiClient::Resource
    belongs_to :user
  end

  class Customer < JsonApiClient::Resource
    belongs_to :user, shallow_path: true
  end
end

# try to find without the nested parameter
MyApi::Account.find(1)
# => raises ArgumentError

# makes request to /users/2/accounts/1
MyApi::Account.where(user_id: 2).find(1)
# => returns ResultSet

# makes request to /customers/1
MyApi::Customer.find(1)
# => returns ResultSet

# makes request to /users/2/customers/1
MyApi::Customer.where(user_id: 2).find(1)
# => returns ResultSet
```

you can also override param name for `belongs_to` association

```ruby
module MyApi
  class Account < JsonApiClient::Resource
    belongs_to :user, param: :customer_id
  end
end

# makes request to /users/2/accounts/1
MyApi::Account.where(customer_id: 2).find(1)
# => returns ResultSet
```

## Custom Methods

You can create custom methods on both collections (class method) and members (instance methods).

```ruby
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
# => <ResultSet of MyApi::User instances>

user = MyApi::User.find(1)
# makes PUT request to /users/1/verify?foo=bar
user.verify(foo: 'bar')
```

## Fetching Includes

[See specification](http://jsonapi.org/format/#fetching-includes)

If the response returns a [compound document](http://jsonapi.org/format/#document-compound-documents), then we should be able to get the related resources.

```ruby
# makes request to /articles/1?include=author,comments.author
results = Article.includes(:author, :comments => :author).find(1)

# should not have to make additional requests to the server
authors = results.map(&:author)

# makes POST request to /articles?include=author,comments.author
article = Article.new(title: 'New one').request_includes(:author, :comments => :author)
article.save

# makes PATCH request to /articles/1?include=author,comments.author
article = Article.find(1)
article.title = 'Changed'
article.request_includes(:author, :comments => :author)
article.save

# request includes will be cleared if response is successful
# to avoid this `keep_request_params` class attribute can be used
Article.keep_request_params = true

# to clear request_includes use
article.reset_request_includes!
```

## Sparse Fieldsets

[See specification](http://jsonapi.org/format/#fetching-sparse-fieldsets)

```ruby
# makes request to /articles?fields[articles]=title,body
article = Article.select("title", "body").first

# should have fetched the requested fields
article.title
# => "Rails is Omakase"

# should not have returned the created_at
article.created_at
# => raise NoMethodError

# or you can use fieldsets from multiple resources
# makes request to /articles?fields[articles]=title,body&fields[comments]=tag
article = Article.select("title", "body",{comments: 'tag'}).first

# makes POST request to /articles?fields[articles]=title,body&fields[comments]=tag
article = Article.new(title: 'New one').request_select(:title, :body, comments: 'tag')
article.save

# makes PATCH request to /articles/1?fields[articles]=title,body&fields[comments]=tag
article = Article.find(1)
article.title = 'Changed'
article.request_select(:title, :body, comments: 'tag')
article.save

# request fields will be cleared if response is successful
# to avoid this `keep_request_params` class attribute can be used
Article.keep_request_params = true

# to clear request fields use
article.reset_request_select!(:comments) # to clear for comments
article.reset_request_select! # to clear for all fields
```

## Sorting

[See specification](http://jsonapi.org/format/#fetching-sorting)

```ruby
# makes request to /people?sort=age
youngest = Person.order(:age).all

# also makes request to /people?sort=age
youngest = Person.order(age: :asc).all

# makes request to /people?sort=-age
oldest = Person.order(age: :desc).all
```

## Paginating

[See specification](http://jsonapi.org/format/#fetching-pagination)

### Requesting

```ruby
# makes request to /articles?page=2&per_page=30
articles = Article.page(2).per(30).to_a

# also makes request to /articles?page=2&per_page=30
articles = Article.paginate(page: 2, per_page: 30).to_a

# keep in mind that page number can be nil - in that case default number will be applied
# also makes request to /articles?page=1&per_page=30
articles = Article.paginate(page: nil, per_page: 30).to_a
```

*Note: The mapping of pagination parameters is done by the `query_builder` which is [customizable](#custom-paginator).*

### Browsing

If the response contains additional pagination links, you can also get at those:

```ruby
articles = Article.paginate(page: 2, per_page: 30).to_a
articles.pages.next
articles.pages.last
```

### Library compatibility

A `JsonApiClient::ResultSet` object should be paginatable with both `kaminari` and `will_paginate`.

## Filtering

[See specifiation](http://jsonapi.org/format/#fetching-filtering)

```ruby
# makes request to /people?filter[name]=Jeff
Person.where(name: 'Jeff').all
```

## Schema

You can define schema within your client model. You can define basic types and set default values if you wish. If you declare a basic type, we will try to cast any input to be that type.

The added benefit of declaring your schema is that you can access fields before data is set (otherwise, you'll get a `NoMethodError`).

**Note: This is completely optional. This will set default values and handle typecasting.**

### Example

```ruby
class User < JsonApiClient::Resource
  property :name, type: :string
  property :is_admin, type: :boolean, default: false
  property :points_accrued, type: :int, default: 0
  property :averge_points_per_day, type: :float
end

# default values
u = User.new

u.name
# => nil

u.is_admin
# => false

u.points_accrued
# => 0

# casting
u.average_points_per_day = "0.3"
u.average_points_per_day
# => 0.3
```

### Types

The basic types that we allow are:

* `:int` or `:integer`
* `:float`
* `:string`
* `:time` - *Note: Include the time zone in the string if it's different than local time.
* `:boolean` - *Note: we will cast the string version of "true" and "false" to their respective values*

Also, we consider `nil` to be an acceptable value and will not cast the value.

Note : Do not map the primary key as int.

## Customizing

### Paths

You can customize this path by changing your resource's `table_name`:

```ruby
module MyApi
  class SomeResource < Base
    def self.table_name
      "foobar"
    end
  end
end

# requests http://example.com/foobar
MyApi::SomeResource.all
```

### Custom headers

You can inject custom headers on resource request by wrapping your code into block:
```ruby
MyApi::SomeResource.with_headers(x_access_token: 'secure_token_here') do
  MyApi::SomeResource.find(1)
end
```

### Connections

You can configure your API client to use a custom connection that implementes the `run` instance method. It should return data that your parser can handle. The default connection class wraps Faraday and lets you add middleware.

```ruby
class NullConnection
  def initialize(*args)
  end

  def run(request_method, path, params: nil, headers: {}, body: nil)
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

```ruby
MyApi::Base.connection do |connection|
  # set OAuth2 headers
  connection.use FaradayMiddleware::OAuth2, 'MYTOKEN'

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

##### Server errors handling

Non-success API response will cause the specific `JsonApiClient::Errors::SomeException` raised, depends on responded HTTP status.
Please refer to [JsonApiClient::Middleware::Status#handle_status](https://github.com/JsonApiClient/json_api_client/blob/master/lib/json_api_client/middleware/status.rb)
method for concrete status-to-exception mapping used out of the box.

JsonApiClient will try determine is failed API response JsonApi-compatible, if so - JsonApi error messages will be parsed from response body, and tracked as a part of particular exception message. In additional, `JsonApiClient::Errors::ServerError` exception will keep the actual HTTP status and message within its message.

##### Custom status handler

You can change handling of response status using `connection_options`. For example you can override 400 status handling.
By default it raises `JsonApiClient::Errors::ClientError` but you can skip exception if you want to process errors from the server.
You need to provide a `proc` which should call `throw(:handled)` default handler for this status should be skipped.
```ruby
class ApiBadRequestHandler
  def self.call(_env)
    # do not raise exception
  end
end

class CustomUnauthorizedError < StandardError
  attr_reader :env

  def initialize(env)
    @env = env
    super('not authorized')
  end
end

MyApi::Base.connection_options[:status_handlers] = {
    400 => ApiBadRequestHandler,
    401 => ->(env) { raise CustomUnauthorizedError, env }
}

module MyApi
  class User < Base
    # will use the customized status_handlers
  end
end

user = MyApi::User.create(name: 'foo')
# server responds with { errors: [ { detail: 'bad request' } ] }
user.errors.messages # { base: ['bad request'] }
# on 401 it will raise CustomUnauthorizedError instead of JsonApiClient::Errors::NotAuthorized
```

##### Specifying an HTTP Proxy

All resources have a class method ```connection_options``` used to pass options to the JsonApiClient::Connection initializer.

```ruby
MyApi::Base.connection_options[:proxy] = 'http://proxy.example.com'
MyApi::Base.connection do |connection|
  # ...
end

module MyApi
  class User < Base
    # will use the customized connection with proxy
  end
end
```

### Custom Parser

You can configure your API client to use a custom parser that implements the `parse` class method.  It should return a `JsonApiClient::ResultSet` instance. You can use it by setting the parser attribute on your model:

```ruby
class MyCustomParser
  def self.parse(klass, response)
    # …
    # returns some ResultSet object
  end
end

class MyApi::Base < JsonApiClient::Resource
  self.parser = MyCustomParser
end
```

### Custom Query Builder

You can customize how the scope builder methods map to request parameters.

```ruby
class MyQueryBuilder
  def initialize(klass); end

  def where(conditions = {})
  end

  # … add order, includes, paginate, page, first, build
end

class MyApi::Base < JsonApiClient::Resource
  self.query_builder = MyQueryBuilder
end
```

### Custom Paginator

You can customize how your resources find pagination information from the response.

If the [existing paginator](https://github.com/JsonApiClient/json_api_client/blob/master/lib/json_api_client/paginating/paginator.rb) fits your requirements but you don't use the default `page` and `per_page` params for pagination, you can customise the param keys as follows:

```ruby
JsonApiClient::Paginating::Paginator.page_param = "number"
JsonApiClient::Paginating::Paginator.per_page_param = "size"
```

Please note that this is a global configuration, so library authors should create a custom paginator that inherits `JsonApiClient::Paginating::Paginator` and configure the custom paginator to avoid modifying global config.

If the [existing paginator](https://github.com/JsonApiClient/json_api_client/blob/master/lib/json_api_client/paginating/paginator.rb) does not fit your needs, you can create a custom paginator:

```ruby
class MyPaginator
  def initialize(result_set, data); end
  # implement current_page, total_entries, etc
end

class MyApi::Base < JsonApiClient::Resource
  self.paginator = MyPaginator
end
```

### NestedParamPaginator

The default `JsonApiClient::Paginating::Paginator` is not strict about how it handles the param keys ([#347](https://github.com/JsonApiClient/json_api_client/issues/347)). There is a second paginator that more rigorously adheres to the JSON:API pagination recommendation style of `page[page]=1&page[per_page]=10`.

If this second style suits your needs better, it is available as a class override:

```ruby
class Order < JsonApiClient::Resource
  self.paginator = JsonApiClient::Paginating::NestedParamPaginator
end
```

You can also extend `NestedParamPaginator` in your custom paginators or assign the `page_param` or `per_page_param` as with the default version above.

### Custom type

If your model must be named differently from classified type of resource you can easily customize it.
It will work both for defined and not defined relationships

```ruby
class MyApi::Base < JsonApiClient::Resource
  resolve_custom_type 'document--files', 'File'
end

class MyApi::File < MyApi::Base
  def self.resource_name
    'document--files'
  end
end
```

### Type Casting

You can define your own types and its casting mechanism for schema.

```ruby
require 'money'
class MyMoneyCaster
  def self.cast(value, default)
    begin
      Money.new(value, "USD")
    rescue ArgumentError
      default
    end
  end
end

JsonApiClient::Schema.register money: MyMoneyCaster

```
and finally

```ruby
class Order < JsonApiClient::Resource
  property :total_amount, type: :money
end

```

### Safe singular resource fetching

That is a bit curios, but `json_api_client` returns an array from `.find` method, always.
The history of this fact was discussed [here](https://github.com/JsonApiClient/json_api_client/issues/75)

So, when we searching for a single resource by primary key, we typically write the things like

```ruby
admin = User.find(id).first
```

The next thing which we need to notice - `json_api_client` will just interpolate the incoming `.find` param to the end of API URL, just like that:

> http://somehost/api/v1/users/{id}

What will happen if we pass the blank id (nil or empty string) to the `.find` method then?.. Yeah, `json_api_client` will try to call the INDEX API endpoint instead of SHOW one:

> http://somehost/api/v1/users/

Lets sum all together - in case if `id` comes blank (from CGI for instance), we can silently receive the `admin` variable equal to some existing resource, with all the consequences.

Even worse, `admin` variable can equal to *random* resource, depends on ordering applied by INDEX endpoint.

If you prefer to get `JsonApiClient::Errors::NotFound` raised, please define in your base Resource class:

```ruby
class Resource < JsonApiClient::Resource
  self.raise_on_blank_find_param = true
end
```

## Contributing

Contributions are welcome! Please fork this repo and send a pull request. Your pull request should have:

* a description about what's broken or what the desired functionality is
* a test illustrating the bug or new feature
* the code to fix the bug

Ideally, the PR has 2 commits - the first showing the failed test and the second with the fix - although this is not
required. The commits will be squashed into master once accepted.

## Changelog

See [changelog](https://github.com/JsonApiClient/json_api_client/blob/master/CHANGELOG.md)
