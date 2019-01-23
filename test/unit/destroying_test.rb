require 'test_helper'

class DestroyingTest < MiniTest::Test

  class CallbackTest < TestResource
    include JsonApiClient::Helpers::Callbacks
    attr_accessor :foo
    after_destroy do
      self.foo = 10
    end
  end

  def test_destroy
    stub_request(:get, "http://example.com/users/1")
      .to_return(headers: {content_type: "application/vnd.api+json"}, body: {
        data: [
          {id: 1, attributes: {name: "Jeff Ching", email_address: "ching.jeff@gmail.com"}}
        ]
      }.to_json)

    users = User.find(1)
    user = users.first
    assert(user.persisted?)
    assert_equal(false, user.new_record?)
    assert_equal(false, user.destroyed?)

    stub_request(:delete, "http://example.com/users/1")
      .to_return(headers: {content_type: "application/vnd.api+json"}, body: {
        data: []
      }.to_json)

    assert(user.destroy, "successful deletion should return truish value")
    assert_equal(false, user.persisted?)
    assert_equal(false, user.new_record?)
    assert(user.destroyed?)
    assert_equal(1, user.id)
  end

  def test_destroy_custom_primary_key
    stub_request(:get, "http://example.com/user_preferences/105")
      .to_return(headers: {content_type: "application/vnd.api+json"}, body: {
        data: [
          {attributes: { user_id: 105, name: "Jeff Ching", email_address: "ching.jeff@gmail.com"}}
        ]
      }.to_json)

    $print_load = true
    user_prefrence = UserPreference.find(105).first
    assert(user_prefrence.persisted?)
    $print_load = false
    assert_equal(false, user_prefrence.new_record?)
    assert_equal(false, user_prefrence.destroyed?)

    stub_request(:delete, "http://example.com/user_preferences/105")
      .to_return(headers: {content_type: "application/vnd.api+json"}, body: {
        data: []
      }.to_json)

    assert(user_prefrence.destroy, "successful deletion should return truish value")
    assert_equal(false, user_prefrence.persisted?)
    assert_equal(false, user_prefrence.new_record?)
    assert(user_prefrence.destroyed?)
    assert_equal(105, user_prefrence.user_id)
  end

  def test_destroy_no_content
    stub_request(:delete, "http://example.com/users/6")
      .to_return(headers: {content_type: "application/vnd.api+json"}, body: nil)

    user = User.new(id: 6)
    assert(user.destroy, "successful deletion should return truish value")
    assert_equal(false, user.persisted?)
  end

  def test_destroy_failure
    stub_request(:get, "http://example.com/users/1")
      .to_return(headers: {content_type: "application/vnd.api+json"}, body: {
        data: [
          {id: 1, attributes: {name: "Jeff Ching", email_address: "ching.jeff@gmail.com"}}
        ]
      }.to_json)

    users = User.find(1)
    user = users.first
    assert(user.persisted?)

    stub_request(:delete, "http://example.com/users/1")
      .to_return(headers: { content_type: "application/json" }, body: {
        data: [],
        errors: [
          {
            status: 400,
            title: "Some failure message",
            source: {
              pointer: "/data/attributes/email_address"
            }
          }
        ]
      }.to_json)

    assert_equal(false, user.destroy, "failed deletion should return falsy value")
    assert_equal(true, user.persisted?, "user should still be persisted because destroy failed")
    assert(user.errors.present?)
    assert_equal("Some failure message", user.errors.messages[:email_address].first, "user should contain the errors describing the failure")
  end

  def test_callbacks
    stub_request(:delete, "http://example.com/callback_tests/6")
        .to_return(headers: {content_type: "application/vnd.api+json"}, body: {
                                                                          data: []
                                                                      }.to_json)

    callback_test = CallbackTest.new(id: 6)
    callback_test.destroy
    assert_equal(10, callback_test.foo)
  end

end
