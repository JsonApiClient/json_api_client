require 'test_helper'

class ResourceTest < MiniTest::Unit::TestCase

  def test_basic
    assert User.is_a?(Class)
  end

  def test_endpoint
    assert_equal "http://localhost:3000/api/1/users", User.resource
  end

  def test_find
    stub_request(:get, "http://localhost:3000/api/1/users/1.json")
      .to_return(headers: {content_type: "application/json"}, body: {
        users: [
          {id: 1, name: "Jeff Ching", email_address: "ching.jeff@gmail.com"}
        ]
      }.to_json)

    users = User.find(1)

    assert_equal 1, users.length

    user = users.first
    assert_equal 1, user.id
    assert_equal "ching.jeff@gmail.com", user.email_address
    assert_equal "Jeff Ching", user.name
  end

  def test_find_by_ids
    stub_request(:get, "http://localhost:3000/api/1/users.json")
      .with(query: {ids: "2,3"})
      .to_return(headers: {content_type: "application/json"}, body: {
        users: [
          {id: 2, name: "Barry Bonds", email_address: "barry@bonds.com"},
          {id: 3, name: "Hank Aaron", email_address: "hank@aaron.com"}
        ]
      }.to_json)

    users = User.find([2,3])
    assert_equal 2, users.length
    assert_equal [2,3], users.map(&:id)
  end

  def test_find_all
    stub_request(:get, "http://localhost:3000/api/1/users.json")
      .to_return(headers: {content_type: "application/json"}, body: {
        users: [
          {id: 1, name: "Jeff Ching", email_address: "ching.jeff@gmail.com"},
          {id: 2, name: "Barry Bonds", email_address: "barry@bonds.com"},
          {id: 3, name: "Hank Aaron", email_address: "hank@aaron.com"}
        ]
      }.to_json)

    users = User.all
    assert users.length > 0
  end

  def test_find_all_with_scope
    stub_request(:get, "http://localhost:3000/api/1/users.json")
      .with(query: {name: "Jeff Ching"})
      .to_return(headers: {content_type: "application/json"}, body: {
        users: [
          {id: 1, name: "Jeff Ching", email_address: "ching.jeff@gmail.com"}
        ]
      }.to_json)

    users = User.where(name: "Jeff Ching").all
    assert_equal 1, users.length
  end

  def test_create
    stub_request(:post, "http://localhost:3000/api/1/users.json")
      .with(body: {user: {name: "Mickey Mantle", email_address: "mickey@mantle.com"}})
      .to_return(headers: {content_type: "application/json"}, body: {
        users: [
          {id: 3, name: "Mickey Mantle", email_address: "mickey@mantle.com"}
        ]
      }.to_json)

    user = User.create(
      name: "Mickey Mantle",
      email_address: "mickey@mantle.com"
    )
    assert_equal 3, user.id
  end

  def test_create_failure
    stub_request(:post, "http://localhost:3000/api/1/users.json")
      .with(body: {user: {name: "", email_address: "mickey@mantle.com"}})
      .to_return(headers: {content_type: "application/json"}, body: {
        users: [],
        meta: {
          status: 400,
          errors: ["Name can't be blank"]
        }
      }.to_json)

    user = User.create(
      name: "",
      email_address: "mickey@mantle.com"
    )
    assert_nil user, "expected failure to not return a Resource instance"
  end

  def test_create_failure_with_custom_handling
    stub_request(:post, "http://localhost:3000/api/1/users.json")
      .with(body: {user: {name: "", email_address: "mickey@mantle.com"}})
      .to_return(headers: {content_type: "application/json"}, body: {
        users: [],
        meta: {
          status: 400,
          errors: ["Name can't be blank"]
        }
      }.to_json)

    response = nil
    user = User.create(
      name: "",
      email_address: "mickey@mantle.com"
    ) do |resp|
      response = resp
    end
    assert response, "expected failure block to yield response object"
    assert_nil user, "expected failure to not return a Resource instance"
  end

  def test_each_on_scope
    stub_request(:get, "http://localhost:3000/api/1/users.json")
      .with(query: {name: "Jeff Ching"})
      .to_return(headers: {content_type: "application/json"}, body: {
        users: [
          {id: 1, name: "Jeff Ching", email_address: "ching.jeff@gmail.com"}
        ]
      }.to_json)

    users = []
    User.where(name: "Jeff Ching").each do |user|
      users.push(user)
    end
    assert_equal 1, users.length
  end

  def test_can_set_arbitrary_attributes
    user = User.new(asdf: "qwer")
    user.foo = "bar"
    assert_equal({asdf: "qwer", foo: "bar"}.stringify_keys, user.attributes)
  end

  def test_dynamic_attribute_methods
    user = User.new(foo: "bar")

    assert user.respond_to? :foo
    assert user.respond_to? :foo=
    assert_equal(user.foo, "bar")

    refute user.respond_to? :bar
    assert user.respond_to? :bar=
    user.bar = "baz"
    assert user.respond_to? :bar

    assert_raises NoMethodError do
      user.quux
    end
  end

  def test_update
    stub_request(:put, "http://localhost:3000/api/1/users/6.json")
      .with(body: {
        user: {
          name: "Foo Bar",
          email_address: "foo2@bar.com"
        }
      })
      .to_return(headers: {content_type: "application/json"}, body: {
        users: [
          {id: 6, name: "Foo Bar", email_address: "foo2@bar.com", another_field: "asdf"}
        ]
      }.to_json)

    user = User.new(id: 6, name: "Foo", email_address: "foo@bar.com")
    user.update_attributes(name: "Foo Bar", email_address: "foo2@bar.com")
    assert_equal("Foo Bar", user.name)
    assert_equal("foo2@bar.com", user.email_address)
    assert_equal("asdf", user.another_field, "updating a record should load new data from server")
  end

  def test_update_failure
    stub_request(:put, "http://localhost:3000/api/1/users/6.json")
      .with(body: {
        user: {
          name: "",
          email_address: "foo2@bar.com"
        }
      })
      .to_return(headers: {content_type: "application/json"}, body: {
        users: [
          {id: 6, name: "", email_address: "foo2@bar.com", another_field: "asdf"}
        ],
        meta: {
          status: 400,
          errors: [
            "Name can't be blank"
          ]
        }
      }.to_json)

    user = User.new(id: 6, name: "Foo", email_address: "foo@bar.com")
    assert_equal(false, user.update_attributes(name: "", email_address: "foo2@bar.com"))
    assert_equal(1, user.errors.length)
    assert_equal("", user.name)
    assert_equal("foo2@bar.com", user.email_address)
  end

  def test_destroy
    stub_request(:delete, "http://localhost:3000/api/1/users/6.json")
      .to_return(headers: {content_type: "application/json"}, body: {
        users: []
      }.to_json)

    user = User.new(id: 6)
    assert(user.destroy, "successful deletion should return truish value")
    assert_equal(false, user.persisted?)
  end

  def test_destroy_failure
    stub_request(:get, "http://localhost:3000/api/1/users/1.json")
      .to_return(headers: {content_type: "application/json"}, body: {
        users: [
          {id: 1, name: "Jeff Ching", email_address: "ching.jeff@gmail.com"}
        ]
      }.to_json)

    users = User.find(1)
    user = users.first
    assert(user.persisted?)

    stub_request(:delete, "http://localhost:3000/api/1/users/1.json")
      .to_return(headers: {content_type: "application/json"}, body: {
        users: [],
        meta: {
          status: 400,
          errors: ["Some failure message"]
        }
      }.to_json)

    assert_equal(false, user.destroy, "failed deletion should return falsy value")
    assert_equal(true, user.persisted?, "user should still be persisted because destroy failed")
  end

  def test_object_equality
    user1 = User.new(asdf: "qwer")
    user2 = User.new(asdf: "qwer")
    assert_equal(user1, user2)
  end

  def test_meta_on_result_set
    stub_request(:get, "http://localhost:3000/api/1/users/1.json")
      .to_return(headers: {content_type: "application/json"}, body: {
        users: [
          {id: 1, name: "Jeff Ching", email_address: "ching.jeff@gmail.com"}
        ],
        meta: {
          ducks: 'quack'
        }
      }.to_json)

    users = User.find(1)

    assert_equal({ 'ducks' => 'quack' }, users.meta)
  end

  def test_meta_on_response
    stub_request(:get, "http://localhost:3000/api/1/users/1.json")
      .to_return(headers: {content_type: "application/json"}, body: {
        users: [
          {id: 1, name: "Jeff Ching", email_address: "ching.jeff@gmail.com"}
        ],
      }.to_json)

    stub_request(:delete, "http://localhost:3000/api/1/users/1.json")
      .to_return(headers: {content_type: "application/json"}, body: {
        users: [
          {id: 1, name: "Jeff Ching", email_address: "ching.jeff@gmail.com"}
        ],
        meta: {
          ducks: 'quack'
        }
      }.to_json)

    user = User.find(1).first
    user.destroy

    assert_equal({ 'ducks' => 'quack' }, user.last_request_meta)
  end
end
