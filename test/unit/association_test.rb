require 'test_helper'

class Owner < TestResource
  has_many :properties
end

class Property < TestResource
  has_one :owner
end

class AssociationTest < MiniTest::Unit::TestCase

  def test_load_has_one
    stub_request(:get, "http://localhost:3000/api/1/properties/1.json")
      .to_return(headers: {content_type: "application/json"}, body: {
        properties: [
          {id: 1, address: "123 Main St.", owner: {id: 1, name: "Jeff Ching"}}
        ]
      }.to_json)

    property = Property.find(1).first
    assert_equal(Owner, property.owner.class)
    assert_equal("Jeff Ching", property.owner.name)
  end

  def test_load_has_many
    stub_request(:get, "http://localhost:3000/api/1/owners.json")
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
    stub_request(:get, "http://localhost:3000/api/1/owners/1.json")
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

end