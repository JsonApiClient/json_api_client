require 'test_helper'

class Country < TestResource

  custom_endpoint :autocomplete, on: :collection, request_method: :get
  custom_endpoint :publish, on: :member, request_method: :post

end

class Pet < TestResource
  self.site = "http://example.com/"
  self.route_format = :dasherized_route

  custom_endpoint :related_pets, on: :member, request_method: :get
  custom_endpoint :vip_pets, on: :collection, request_method: :get

end

class MythicBeasts < TestResource
  self.site = "http://example.com/"
  self.route_format = :camelized_route

  custom_endpoint :related_beasts, on: :member, request_method: :get
  custom_endpoint :ancient_beasts, on: :collection, request_method: :get

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

  def test_member_dasherized_route_format_converts_custom_endpoint
    stub_request(:get, "http://example.com/pets/1/related-pets")
      .to_return(headers: {content_type: "application/vnd.api+json"}, body: {
        data: [
          {id: 1, type: 'pets'},
          {id: 2, type: 'pets'},
        ]
      }.to_json)

    pet = Pet.new({id: 1, name: 'Otto'})
    pet.mark_as_persisted!

    related_pets = pet.related_pets

    assert_equal 2, related_pets.length
    assert_equal [1,2], related_pets.map(&:id)
  end

  def test_collection_dasherized_route_format_converts_custom_endpoint
    stub_request(:get, "http://example.com/pets/vip-pets")
      .to_return(headers: {content_type: "application/vnd.api+json"}, body: {
        data: [
          {id: 4, type: 'pets'},
          {id: 5, type: 'pets'},
          {id: 6, type: 'pets'}
        ]
      }.to_json)

      vip_pets = Pet.vip_pets

      assert_equal 3, vip_pets.length
      assert_equal [4,5,6], vip_pets.map(&:id)
  end

  def test_member_camelized_route_format_converts_custom_endpoint
    stub_request(:get, "http://example.com/mythicBeasts/1/relatedBeasts")
      .to_return(headers: {content_type: "application/vnd.api+json"}, body: {
        data: [
          {id: 1, type: 'mythic-beasts'},
          {id: 2, type: 'mythic-beasts'},
        ]
      }.to_json)

    dragon = MythicBeasts.new({id: 1, name: 'Dragon'})
    dragon.mark_as_persisted!

    related_beasts = dragon.related_beasts

    assert_equal 2, related_beasts.length
    assert_equal [1,2], related_beasts.map(&:id)
  end

  def test_collection_camelized_route_format_converts_custom_endpoint
    stub_request(:get, "http://example.com/mythicBeasts/ancientBeasts")
      .to_return(headers: {content_type: "application/vnd.api+json"}, body: {
        data: [
          {id: 4, type: 'mythic-beasts'},
          {id: 5, type: 'mythic-beasts'},
          {id: 6, type: 'mythic-beasts'}
        ]
      }.to_json)

      ancient_beasts = MythicBeasts.ancient_beasts

      assert_equal 3, ancient_beasts.length
      assert_equal [4,5,6], ancient_beasts.map(&:id)
  end

end
