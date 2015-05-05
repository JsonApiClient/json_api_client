require 'test_helper'

class ServerSideErrorTest < MiniTest::Unit::TestCase

  def test_can_handle_validations
    stub_request(:post, "http://example.com/users")
      .to_return(headers: {content_type: "application/vnd.api+json"}, body: {
        errors: [
          {
            id: 'someguid',
            status: "400",
            title: "Email address is invalid"
          }
        ] 
      }.to_json)

    user = User.create(name: 'Bob', email_address: 'invalid email')
    assert !user.persisted?
    assert user.errors.present?
    assert_equal ["Email address is invalid"], user.errors.full_messages
  end

  def test_can_handle_validation_strings
    stub_request(:post, "http://example.com/users")
      .to_return(headers: {content_type: "application/vnd.api+json"}, body: {
        errors: ["Email address is invalid"]
      }.to_json)

    user = User.create(name: 'Bob', email_address: 'invalid email')
    assert !user.persisted?
    assert user.errors.present?
    assert_equal ["Email address is invalid"], user.errors.full_messages
  end

end