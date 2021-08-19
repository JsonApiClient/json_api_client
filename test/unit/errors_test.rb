require 'test_helper'

class ErrorsTest < MiniTest::Test

  def test_connection_errors
    stub_request(:get, "http://example.com/users")
      .to_raise(Faraday::ConnectionFailed.new("specific message"))

    err = assert_raises JsonApiClient::Errors::ConnectionError do
      User.all
    end

    assert_match(/specific message/, err.message)
  end

  def test_timeout_errors
    stub_request(:get, "http://example.com/users")
      .to_timeout

    assert_raises JsonApiClient::Errors::ConnectionError do
      User.all
    end
  end

  def test_internal_server_error_with_plain_text_response
    stub_request(:get, "http://example.com/users")
      .to_return(headers: {content_type: "text/plain"}, status: 500, body: "something went wrong")

    exception = assert_raises(JsonApiClient::Errors::InternalServerError) { User.all }
    assert_equal '500 Internal Server Error', exception.message
  end

  def test_internal_server_error_with_json_api_response
    stub_request(:get, "http://example.com/users").to_return(
      headers: {content_type: "application/vnd.api+json"},
      status: 500,
      body: {errors: [{title: "Some special error"}]}.to_json
    )

    exception = assert_raises(JsonApiClient::Errors::InternalServerError) { User.all }
    assert_equal '500 Internal Server Error (Some special error)', exception.message
  end

  def test_500_errors_with_plain_text_response
    stub_request(:get, "http://example.com/users")
      .to_return(headers: {content_type: "text/plain"}, status: 503, body: "service unavailable")

    exception = assert_raises(JsonApiClient::Errors::ServerError) { User.all }
    assert_equal '503 Service Unavailable', exception.message
  end

  def test_500_errors_with_with_json_api_response
    stub_request(:get, "http://example.com/users").to_return(
      headers: {content_type: "application/vnd.api+json"},
      status: 503,
      body: {errors: [{title: "Timeout error"}]}.to_json
    )

    exception = assert_raises(JsonApiClient::Errors::ServerError) { User.all }
    assert_equal '503 Service Unavailable (Timeout error)', exception.message
  end

  def test_not_found
    stub_request(:get, "http://example.com/users")
      .to_return(status: 404, body: "something irrelevant")

    assert_raises JsonApiClient::Errors::NotFound do
      User.all
    end
  end

  def test_conflict
    stub_request(:get, "http://example.com/users")
      .to_return(status: 409, body: "something irrelevant")

    assert_raises JsonApiClient::Errors::Conflict do
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

  def test_not_authorized
    stub_request(:get, "http://example.com/users")
      .to_return(headers: {content_type: "text/plain"}, status: 401, body: "not authorized")

    assert_raises JsonApiClient::Errors::NotAuthorized do
      User.all
    end
  end

  def test_request_timeout
    stub_request(:get, "http://example.com/users")
      .to_return(headers: {content_type: "text/plain"}, status: 408, body: "request timeout")

    assert_raises JsonApiClient::Errors::RequestTimeout do
      User.all
    end
  end

  def test_too_many_requests
    stub_request(:get, "http://example.com/users")
      .to_return(headers: {content_type: "text/plain"}, status: 429, body: "too many requests")

    assert_raises JsonApiClient::Errors::TooManyRequests do
      User.all
    end
  end

  def test_bad_gateway
    stub_request(:get, "http://example.com/users")
      .to_return(headers: {content_type: "text/plain"}, status: 502, body: "bad gateway")

    assert_raises JsonApiClient::Errors::BadGateway do
      User.all
    end
  end

  def test_service_unavailable
    stub_request(:get, "http://example.com/users")
      .to_return(headers: {content_type: "text/plain"}, status: 503, body: "service unavailable")

    assert_raises JsonApiClient::Errors::ServiceUnavailable do
      User.all
    end
  end

  def test_gateway_timeout
    stub_request(:get, "http://example.com/users")
      .to_return(headers: {content_type: "text/plain"}, status: 504, body: "gateway timeout")

    assert_raises JsonApiClient::Errors::GatewayTimeout do
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
