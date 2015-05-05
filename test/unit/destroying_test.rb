require 'test_helper'

class DestroyingTest < MiniTest::Unit::TestCase

  def test_destroy
    stub_request(:delete, "http://example.com/users/6")
      .to_return(headers: {content_type: "application/vnd.api+json"}, body: {
        data: []
      }.to_json)

    user = User.new(id: 6)
    assert(user.destroy, "successful deletion should return truish value")
    assert_equal(false, user.persisted?)
  end

  def test_destroy_failure
    stub_request(:get, "http://example.com/users/1")
      .to_return(headers: {content_type: "application/vnd.api+json"}, body: {
        data: [
          {id: 1, name: "Jeff Ching", email_address: "ching.jeff@gmail.com"}
        ]
      }.to_json)

    users = User.find(1)
    user = users.first
    assert(user.persisted?)

    stub_request(:delete, "http://example.com/users/1")
      .to_return(headers: {content_type: "application/json"}, body: {
        data: [],
        errors: [{
          status: 400,
          errors: ["Some failure message"]
        }]
      }.to_json)

    assert_equal(false, user.destroy, "failed deletion should return falsy value")
    assert_equal(true, user.persisted?, "user should still be persisted because destroy failed")
  end

end