require 'test_helper'

class Country < TestResource

  custom_endpoint :autocomplete, on: :collection, request_method: :get
  custom_endpoint :publish, on: :member, request_method: :post

end

class CustomEndpointTest < MiniTest::Test

  def test_collection_get
    stub_request(:get, "http://example.com/countries/autocomplete?starts_with=bel")
      .to_return(headers: {content_type: "application/vnd.api+json"}, body: {
        data: [
          {id: 1, name: 'Belgium'},
          {id: 2, name: 'Belarus'}
        ]
      }.to_json)

    countries = Country.autocomplete(starts_with: "bel")
    assert_equal 2, countries.length
    assert(countries.all?{|country| country.is_a?(Country)})
    assert_equal [1,2], countries.map(&:id)
  end

  def test_member_post
    stub_request(:post, "http://example.com/countries/1/publish")
      .to_return(headers: {content_type: "application/vnd.api+json"}, body: {
        data: [
          {id: 1, name: 'Belgium'}
        ]
      }.to_json)

    country = Country.new({
      id: 1,
      name: 'Belgium'
    })
    assert(country.publish)
  end

  def test_collection_methods_should_not_add_methods_to_all_classes
    assert !Class.respond_to?(:autocomplete), "adding a custom method should not add methods to all classes"
  end

end
