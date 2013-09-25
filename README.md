# JsonApiClient

## Usage

```
module MyApi
  class User < JsonApiClient::Resource
    belongs_to :accounts

  end
end

MyApi::User.all
MyApi::User.find(1, account_id: 1)
MyApi::User.where(account_id: 1).all

MyApi::User.where().order().includes()

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