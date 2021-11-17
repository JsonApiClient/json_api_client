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

    assert_raises JsonApiClient::Errors::InternalServerError do
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

    assert_raises JsonApiClient::Errors::InternalServerError do
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

  def test_server_responding_with_400_status
    stub_request(:get, "http://example.com/users/1")
        .to_return(headers: {content_type: "application/vnd.api+json"}, body: {
            meta: {
                status: 400,
                message: "Bad Request"
            }
        }.to_json)

    assert_raises JsonApiClient::Errors::ClientError do
      User.find(1)
    end
  end

  def test_server_responding_with_401_status
    stub_request(:get, "http://example.com/users/1")
        .to_return(headers: {content_type: "application/vnd.api+json"}, body: {
            meta: {
                status: 401,
                message: "Not Authorized"
            }
        }.to_json)

    assert_raises JsonApiClient::Errors::NotAuthorized do
      User.find(1)
    end
  end

  def test_server_responding_with_400_status_in_meta_with_custom_status_handler
    stub_request(:get, "http://example.com/user_with_custom_status_handlers/1")
        .to_return(headers: {content_type: "application/vnd.api+json"}, body: {
            meta: {
                status: 400,
                message: "Bad Request"
            }
        }.to_json)

    UserWithCustomStatusHandler.find(1)
  end

  def test_server_responding_with_401_status_in_meta_with_custom_status_handler
    stub_request(:get, "http://example.com/user_with_custom_status_handlers/1")
        .to_return(headers: {content_type: "application/vnd.api+json"}, body: {
            meta: {
                status: 401,
                message: "Not Authorized"
            }
        }.to_json)

    assert_raises CustomUnauthorizedError do
      UserWithCustomStatusHandler.find(1)
    end
  end

  def test_server_responding_with_400_status_with_custom_status_handler
    stub_request(:post, "http://example.com/user_with_custom_status_handlers")
        .with(headers: { content_type: 'application/vnd.api+json', accept: 'application/vnd.api+json' }, body: {
            data: {
                type: 'user_with_custom_status_handlers',
                attributes: {
                    name: 'foo'
                }
            }
        }.to_json)
        .to_return(status: 400, headers: { content_type: "application/vnd.api+json" }, body: {
            errors: [
                {
                    status: '400',
                    detail: 'Bad Request'
                }
            ]
        }.to_json)

    user = UserWithCustomStatusHandler.create(name: 'foo')
    refute user.persisted?
    expected_errors = { base: ['Bad Request'] }
    assert_equal expected_errors, user.errors.messages
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
