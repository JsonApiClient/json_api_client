require 'legacy_test_helper'

class Country < LegacyTestResource

  custom_endpoint :autocomplete, on: :collection, request_method: :get
  custom_endpoint :publish, on: :member, request_method: :post

end

class CustomEndpointTest < MiniTest::Unit::TestCase

  def test_collection_get
    stub_request(:get, "http://localhost:3000/api/1/countries/autocomplete.json?starts_with=bel")
      .to_return(headers: {content_type: "application/json"}, body: {
        countries: [
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
    stub_request(:post, "http://localhost:3000/api/1/countries/1/publish.json")
      .to_return(headers: {content_type: "application/json"}, body: {
        countries: [
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