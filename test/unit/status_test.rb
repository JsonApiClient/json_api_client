require 'test_helper'

class StatusTest < MiniTest::Unit::TestCase
  def setup
    @api_url = "http://localhost:3000/api/1/users/1.json"
  end

  def test_server_responding_with_status_meta
    stub_request(:get, @api_url)
      .to_return(headers: {content_type: "application/json"}, body: {
        meta: {
          status: 500,
          message: "An internal server error has occurred."
        }
      }.to_json)

    server_error = assert_raises JsonApiClient::Errors::ServerError do
      users = User.find(1)
    end
    assert_equal server_error.message, "Internal server error at: #{@api_url}"
  end

  def test_server_responding_with_http_status
    stub_request(:get, @api_url)
      .to_return(headers: {
        content_type: "text/plain"
      }, 
      status: 500,
      body: "something irrelevant")

    assert_raises JsonApiClient::Errors::ServerError do
      users = User.find(1)
    end
  end

  def test_server_responding_with_404_status
    stub_request(:get, @api_url)
      .to_return(headers: {
        content_type: "text/plain"
      }, 
      status: 404,
      body: "something irrelevant")

    not_found_exception = assert_raises JsonApiClient::Errors::NotFound do
      users = User.find(1)
    end

    assert_equal not_found_exception.message, "Couldn't find resource at: #{@api_url}"
  end

  def test_server_responding_with_404_status_meta
    stub_request(:get, @api_url)
      .to_return(headers: {content_type: "application/json"}, body: {
        meta: {
          status: 404,
          message: "Blah blah"
        }
      }.to_json)

    assert_raises JsonApiClient::Errors::NotFound do
      users = User.find(1)
    end
  end

end