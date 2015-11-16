require 'test_helper'

class ErrorsTest < MiniTest::Test

  def test_connection_errors
    stub_request(:get, "http://example.com/users")
      .to_raise(Faraday::ConnectionFailed)

    assert_raises JsonApiClient::Errors::ConnectionError do
      User.all
    end
  end

  def test_timeout_errors
    stub_request(:get, "http://example.com/users")
      .to_timeout

    assert_raises JsonApiClient::Errors::ConnectionError do
      User.all
    end 
  end

  def test_500_errors
    stub_request(:get, "http://example.com/users")
      .to_return(headers: {content_type: "text/plain"}, status: 500, body: "something went wrong")

    assert_raises JsonApiClient::Errors::ServerError do
      User.all
    end
  end

  def test_not_found
    stub_request(:get, "http://example.com/users")
      .to_return(status: 404, body: "something irrelevant")

    assert_raises JsonApiClient::Errors::NotFound do
      User.all
    end
  end

  def test_access_denied
    stub_request(:get, "http://example.com/users")
      .to_return(headers: {content_type: "text/plain"}, status: 403, body: "access denied")

    assert_raises JsonApiClient::Errors::AccessDenied do
      User.all
    end
  end

  def test_access_denied
    stub_request(:get, "http://example.com/users")
      .to_return(headers: {content_type: "text/plain"}, status: 401, body: "not authorized")

    assert_raises JsonApiClient::Errors::NotAuthorized do
      User.all
    end
  end

  def test_errors_are_rescuable_by_default_rescue
    begin
      raise JsonApiClient::Errors::ApiError, "Something bad happened"
    rescue => e
      assert e.is_a?(JsonApiClient::Errors::ApiError)
    end
  end

  def test_unknown_response_code
    stub_request(:get, "http://example.com/users")
      .to_return(headers: {content_type: "text/plain"}, status: 699, body: "lol wut")

    assert_raises JsonApiClient::Errors::UnexpectedStatus do
      User.all
    end

  end

end