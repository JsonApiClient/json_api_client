require 'legacy_test_helper'

class Owner < LegacyTestResource
  has_many :properties
end

class Property < LegacyTestResource
  has_one :owner
end

class Specified < LegacyTestResource
  belongs_to :foo, class_name: "Property"
  has_many :bars, class_name: "Owner"
end

module Namespaced
  class Owner < LegacyTestResource
    has_many :properties
  end

  class Property < LegacyTestResource
    belongs_to :owner
  end
end

class AssociationTest < MiniTest::Unit::TestCase

  def test_load_has_one
    stub_request(:get, "http://localhost:3000/api/1/properties/1")
      .to_return(headers: {content_type: "application/json"}, body: {
        properties: [
          {id: 1, address: "123 Main St.", owner: {id: 1, name: "Jeff Ching"}}
        ]
      }.to_json)

    property = Property.find(1).first
    assert_equal(Owner, property.owner.class)
    assert_equal("Jeff Ching", property.owner.name)
  end

  def test_load_has_one_nil
    stub_request(:get, "http://localhost:3000/api/1/properties/1")
      .to_return(headers: {content_type: "application/json"}, body: {
        properties: [
          {id: 1, address: "123 Main St.", owner: nil}
        ]
      }.to_json)

    property = Property.find(1).first
    assert_equal(nil, property.owner)
  end

  def test_load_has_many
    stub_request(:get, "http://localhost:3000/api/1/owners")
      .to_return(headers: {content_type: "application/json"}, body: {
        owners: [
          {id: 1, name: "Jeff Ching", properties: [
            {id: 1, address: "123 Main St."},
            {id: 2, address: "223 Elm St."}
          ]},
          {id: 2, name: "Barry Bonds", properties: []},
          {id: 3, name: "Hank Aaron", properties: [
            {id: 3, address: "314 150th Ave"}
          ]}
        ]
      }.to_json)

    owners = Owner.all
    jeff = owners[0]
    assert_equal("Jeff Ching", jeff.name)
    assert_equal(2, jeff.properties.length)
    assert_equal(Property, jeff.properties.first.class)
    assert_equal("123 Main St.", jeff.properties.first.address)
  end

  def test_load_has_many_single_entry
    stub_request(:get, "http://localhost:3000/api/1/owners/1")
      .to_return(headers: {content_type: "application/json"}, body: {
        owners: [
          {id: 1, name: "Jeff Ching", properties: {id: 1, address: "123 Main St."}}
        ]
      }.to_json)

    owner = Owner.find(1).first
    assert_equal(1, owner.properties.length)
    assert_equal(Property, owner.properties.first.class)
    assert_equal("123 Main St.", owner.properties.first.address)
  end

  def test_namespaced_association_class_discovery
    has_many = Namespaced::Owner.associations.first
    assert_equal(Namespaced::Property, has_many.association_class)

    has_one = Namespaced::Property.associations.first
    assert_equal(Namespaced::Owner, has_one.association_class)
  end

  def test_specified_association_class
    has_one = Specified.associations.first
    assert_equal(Property, has_one.association_class)

    has_many = Specified.associations.last
    assert_equal(Owner, has_many.association_class)
  end

  def test_association_building
    assert_equal 1, Owner.associations.length
    assert_equal 1, Property.associations.length
    assert_equal 2, Specified.associations.length
    assert_equal 1, Namespaced::Owner.associations.length
    assert_equal 1, Namespaced::Property.associations.length
  end

  def test_belongs_to_path
    assert_equal([:foo_id], Specified.prefix_params)
    assert_equal("foos/%{foo_id}", Specified.prefix_path)
    assert_raises ArgumentError do
      Specified.path({})
    end
    assert_equal("foos/%{foo_id}/specifieds", Specified.path)
    assert_equal("foos/1/specifieds", Specified.path({foo_id: 1}))
  end

  def test_find_belongs_to
    stub_request(:get, "http://localhost:3000/api/1/foos/1/specifieds")
      .to_return(headers: {content_type: "application/json"}, body: {
        specifieds: [
          {id: 1, name: "Jeff Ching", bars: [{id: 1, address: "123 Main St."}]}
        ]
      }.to_json)

    specifieds = Specified.where(foo_id: 1).all
    assert_equal(1, specifieds.length)
  end

  def test_can_handle_non_symbolized_keys
    skip # legacytest
    stub_request(:post, "http://localhost:3000/api/1/foos/10/specifieds")
      .to_return(headers: {content_type: "application/json"}, body: {
        specifieds: [
          {id: 12, name: "Blah", bars: [{id: 1, address: "123 Main St."}]}
        ]
      }.to_json)

    specified = Specified.create({
      "id" => 12,
      "foo_id" => 10,
      "name" => "Blah"
    })
  end

end
