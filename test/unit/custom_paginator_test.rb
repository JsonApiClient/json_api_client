require 'test_helper'

class CustomPaginatorTest < MiniTest::Test

  class CustomPaginator < JsonApiClient::Paginating::Paginator
    def total_entries
      42
    end
  end

  class Book < JsonApiClient::Resource
    self.site = "http://example.com/"
    self.paginator = CustomPaginator
  end

  def test_can_override
    stub_request(:get, "http://example.com/books")
      .to_return(headers: {content_type: "application/vnd.api+json"}, body: {
        data: []
      }.to_json)

    books = Book.all
    assert_equal 42, books.total_count
    assert_equal 42, books.total_entries
  end
end
