require 'test_helper'

class CustomPaginatorTest < MiniTest::Test

  class CustomPaginator < JsonApiClient::Paginating::Paginator
    self.page_param = 'pagina'
    self.per_page_param = 'limit'
  end

  class Book < JsonApiClient::Resource
    self.site = "http://example.com/"
    self.paginator = CustomPaginator
  end

  def test_can_override_query_param_names
    stub_request(:get, "http://example.com/books")
      .with(query: {page: {pagina: 3, limit: 6}})
      .to_return(headers: {content_type: "application/vnd.api+json"}, body: {
        data: []
      }.to_json)

    Book.paginate(page: 3, per_page: 6).to_a
  end

end
