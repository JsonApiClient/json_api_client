require 'test_helper'

class StatusTest < MiniTest::Test

  def test_server_responding_with_status_meta
    stub_request(:get, "http://example.com/users/1")
      .to_return(headers: {content_type: "application/vnd.api+json"}, body: {
        meta: {
          status: 500,
          message: "An internal server error has occurred."
        }
      }.to_json)

    assert_raises JsonApiClient::Errors::ServerError do
      User.find(1)
    end
  end

  def test_server_responding_with_http_status
    stub_request(:get, "http://example.com/users/1")
      .to_return(headers: {
        content_type: "text/plain"
      },
      status: 500,
      body: "something irrelevant")

    assert_raises JsonApiClient::Errors::ServerError do
      User.find(1)
    end
  end

  def test_server_responding_with_404_status
    stub_request(:get, "http://example.com/users/1")
      .to_return(headers: {
        content_type: "text/plain"
      },
      status: 404,
      body: "something irrelevant")

    assert_raises JsonApiClient::Errors::NotFound do
      User.find(1)
    end
  end

  def test_server_responding_with_404_status_meta
    stub_request(:get, "http://example.com/users/1")
      .to_return(headers: {content_type: "application/vnd.api+json"}, body: {
        meta: {
          status: 404,
          message: "Blah blah"
        }
      }.to_json)

    assert_raises JsonApiClient::Errors::NotFound do
      User.find(1)
    end
  end

  def test_server_responding_with_408_status
    stub_request(:get, "http://example.com/users/1")
      .to_return(headers: {content_type: "application/vnd.api+json"}, body: {
        meta: {
          status: 408,
          message: "Request timeout"
        }
      }.to_json)

    assert_raises JsonApiClient::Errors::ClientError do
      User.find(1)
    end
  end

  def test_server_responding_with_422_status
    stub_request(:get, "http://example.com/users/1")
      .to_return(headers: {content_type: "application/vnd.api+json"}, body: {
        meta: {
          status: 422
        }
      }.to_json)

    # We want to test that this response does not raise an error
    User.find(1)
  end
end
