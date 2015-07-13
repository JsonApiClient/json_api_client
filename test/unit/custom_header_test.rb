require 'test_helper'

class CustomHeaderTest < MiniTest::Test

  class CustomHeaderResource < TestResource
    include JsonApiClient::Helpers::CustomHeaders
  end
  CustomHeaderResource.connection do |conn|
    conn.use JsonApiClient::Middleware::CustomHeaders, CustomHeaderResource
  end

  def test_can_set_custom_headers
    stub_request(:get, "http://example.com/custom_header_resources/1")
      .with(headers: {"X-My-Header" => "asdf"})
      .to_return(headers: {content_type: "application/vnd.api+json"}, body: {
        data: {
          type: "custom_header_resources",
          id: "1",
          attributes: {
            title: "Rails is Omakase"
          }
        }
      }.to_json)

    CustomHeaderResource.with_headers(x_my_header: "asdf") do
      resources = CustomHeaderResource.find(1)
    end
  end

end