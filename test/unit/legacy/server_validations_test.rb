require 'legacy_test_helper'

class ServerValidationsTest < MiniTest::Unit::TestCase

  def test_update_validation_error
    stub_request(:put, "http://localhost:3000/api/1/users/6.json")
      .with(body: {
        user: {
          name: "Foo Bar",
          email_address: "invalid email address"
        }
      })
      .to_return(headers: {content_type: "application/json"}, status: 400, body: {
        users: [
          {id: 6, name: "Foo Bar", email_address: "invalid email address"}
        ],
        meta: {
          errors: [
            "Email address is invalid"
          ]
        }
      }.to_json)

    user = User.new(id: 6, name: "Foo", email_address: "foo@bar.com")
    assert(!user.update_attributes(name: "Foo Bar", email_address: "invalid email address"), "invalid request should return falsy value")
    assert_equal(1, user.errors.length)
  end

  def test_create_validation_error
    stub_request(:post, "http://localhost:3000/api/1/users.json")
      .with(body: {
        user: {
          name: "Foo Bar",
          email_address: "invalid email address"
        }
      })
      .to_return(headers: {content_type: "application/json"}, status: 400, body: {
        users: [
          {id: 6, name: "Foo Bar", email_address: "invalid email address"}
        ],
        meta: {
          errors: [
            "Email address is invalid"
          ]
        }
      }.to_json)

    user = User.new(name: "Foo", email_address: "foo@bar.com")
    assert(!user.update_attributes(name: "Foo Bar", email_address: "invalid email address"), "invalid request should return falsy value")
    assert_equal(1, user.errors.length)
  end

  def test_class_create_validation_error
    stub_request(:post, "http://localhost:3000/api/1/users.json")
      .with(body: {
        user: {
          name: "Foo Bar",
          email_address: "invalid email address"
        }
      })
      .to_return(headers: {content_type: "application/json"}, status: 400, body: {
        users: [
          {id: 6, name: "Foo Bar", email_address: "invalid email address"}
        ],
        meta: {
          errors: [
            "Email address is invalid"
          ]
        }
      }.to_json)

    assert(!User.create(name: "Foo Bar", email_address: "invalid email address"), "invalid request should return falsy value")
  end
end