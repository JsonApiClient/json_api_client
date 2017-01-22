require 'test_helper'

class ServerSideErrorTest < MiniTest::Test

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
        errors: [{title: "Email address is invalid"}]
      }.to_json)

    user = User.create(name: 'Bob', email_address: 'invalid email')
    assert !user.persisted?
    assert user.errors.present?
    assert_equal ["Email address is invalid"], user.errors.full_messages
  end

  def test_can_handle_key_formatted_attribute_validation_strings
    with_altered_config(User, :json_key_format => :dasherized_key) do
      stub_request(:post, "http://example.com/users")
        .to_return(headers: {content_type: "application/vnd.api+json"}, body: {
          errors: [{source: {pointer: "/data/attributes/email-address"}, title: "Email address is invalid"}]
        }.to_json)
      
      user = User.create(name: 'Bob', email_address: 'invalid email')
      assert !user.persisted?
      assert user.errors.present?
      assert_equal ["Email address is invalid"], user.errors[:email_address]
    end
  end

end