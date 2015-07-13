require 'test_helper'

class CustomHeaderTest < MiniTest::Test

  class CustomHeaderResource < TestResource
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

  def test_class_method_headers
    stub_request(:post, "http://example.com/custom_header_resources")
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
      resources = CustomHeaderResource.create(foo: "bar")
    end
  end

  def test_multiple_threads
    thread_count = 10

    # set up expectations/stubs
    thread_count.times do |i|
      stub_request(:get, "http://example.com/custom_header_resources/#{i}")
        .with(headers: {"X-My-Header" => "Header #{i}"})
        .to_return(headers: {content_type: "application/vnd.api+json"}, body: {
          data: {
            type: "custom_header_resources",
            id: "#{i}",
            attributes: {
              title: "Rails is Omakase"
            }
          }
        }.to_json)
    end

    @ready = false
    threads = []

    # create threads and set up to wait and try and fire them off at the same time
    thread_count.times do |i|
      threads << Thread.new do
        CustomHeaderResource.with_headers(x_my_header: "Header #{i}") do
          wait_for { @ready }
          resources = CustomHeaderResource.find(i)
        end
      end
    end

    @ready = true

    threads.each_with_index do |thread, i|
      resource = thread.value.first
      assert_equal i, resource.id.to_i
    end
  end

  protected

  def wait_for
    Timeout.timeout 1 do
      sleep 0.001 until yield
    end
  end

end