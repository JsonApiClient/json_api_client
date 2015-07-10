require 'test_helper'

class Owner < TestResource
  has_many :properties
end

class Property < TestResource
  has_one :owner
end

class Specified < TestResource
  belongs_to :foo, class_name: "Property"
  has_many :bars, class_name: "Owner"
end

module Namespaced
  class Owner < TestResource
    has_many :properties
  end

  class Property < TestResource
    belongs_to :owner
  end
end

class AssociationTest < MiniTest::Test

  def test_load_has_one
    stub_request(:get, "http://example.com/properties/1")
      .to_return(headers: {content_type: "application/vnd.api+json"}, body: {
        data: [
          {
            id: 1,
            attributes: {
              address: "123 Main St."
            },
            relationships: {
              owner: {
                data: {id: 1, type: 'owner'}
              }
            }
          }
        ],
        included: [
          {
            id: 1,
            type: 'owner',
            attributes: {
              name: 'Jeff Ching'
            }
          }
        ]

      }.to_json)
    property = Property.find(1).first
    assert_equal(Owner, property.owner.class)
    assert_equal("Jeff Ching", property.owner.name)
  end

  def test_load_has_one_with_include
    stub_request(:get, "http://example.com/properties/1?include=owner")
        .to_return(
            headers: {
                content_type: "application/vnd.api+json"
            }, body: {
                 data: [
                     {
                         id: 1,
                         attributes: {
                             address: "123 Main St."
                         },
                         relationships: {
                             owner: {
                                 data: {id: 1, type: 'owner'}
                             }
                         }
                     }
                 ],
                 included: [
                     {
                         id: 1,
                         type: 'owner',
                         attributes: {
                             name: 'Jeff Ching'
                         }
                     }
                 ]

             }.to_json)
    property = Property.includes(:owner).find(1).first
    assert_equal("Jeff Ching", property.owner.name)
  end

  def test_load_has_one_nil
    stub_request(:get, "http://example.com/properties/1")
      .to_return(headers: {content_type: "application/vnd.api+json"}, body: {
        data: [
          {
            id: 1,
            attributes: {
              address: "123 Main St."
            },
            relationships: {
              owner: {
                links: {
                  self: 'http://example.com/properties/1/links/owner',
                  related: 'http://example.com/people/1'
                }
              }
            }
          }
        ]
      }.to_json)

    property = Property.find(1).first
    assert_equal(nil, property.owner)
  end

  def test_load_has_many
    stub_request(:get, "http://example.com/owners")
      .to_return(headers: {content_type: "application/vnd.api+json"}, body: {
        data: [
          {
            id: 1,
            attributes: {
              name: "Jeff Ching",
            },
            relationships: {
              properties: {
                data: [
                  {id: 1, type: 'property'},
                  {id: 2, type: 'property'}
                ]
              }
            }
          },
          {id: 2, attributes: {name: "Barry Bonds"}},
          {
            id: 3,
            attributes: {
              name: "Hank Aaron"
            },
            relationships: {
              properties: {
                data: [
                  {id: 3, type: 'property'}
                ]
              }
            }
          }
        ],
        included: [
          {
            id: 1,
            type: 'property',
            attributes: {address: "123 Main St."}
          },
          {
            id: 2,
            type: 'property',
            attributes: {address: "223 Elm St."}
          },
          {
            id: 3,
            type: 'property',
            attributes: {address: "314 150th Ave"}
          }
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
    stub_request(:get, "http://example.com/owners/1")
      .to_return(headers: {content_type: "application/vnd.api+json"}, body: {
        data: [
          {
            id: 1,
            attributes: {name: "Jeff Ching"},
            relationships: {
              properties: {
                data: [{type: 'property', id: 1}]
              }
            }
          }
        ],
        included: [
          {
            id: 1,
            type: 'property',
            attributes: {
              address: "123 Main St."
            }
          }
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
    stub_request(:get, "http://example.com/foos/1/specifieds")
      .to_return(headers: {content_type: "application/vnd.api+json"}, body: {
        data: [
          {id: 1, name: "Jeff Ching", bars: [{id: 1, attributes: {address: "123 Main St."}}]}
        ]
      }.to_json)

    specifieds = Specified.where(foo_id: 1).all
    assert_equal(1, specifieds.length)
  end

  def test_can_handle_creating
    stub_request(:post, "http://example.com/foos/10/specifieds")
      .to_return(headers: {content_type: "application/vnd.api+json"}, body: {
        data: [
          {id: 12, attributes: {name: "Blah"}}
        ]
      }.to_json)

    specified = Specified.create({
      :id => 12,
      :foo_id => 10,
      :name => "Blah"
    })
  end

  def test_find_belongs_to_params_unchanged
    stub_request(:get, "http://example.com/foos/1/specifieds")
      .to_return(headers: {
        content_type: "application/vnd.api+json"
      }, body: {
        data: [
          {
            id: 1,
            name: "Jeff Ching",
            bars: [{id: 1, attributes: {address: "123 Main St."}}]
          }
        ]
      }.to_json)

    specifieds = Specified.where(foo_id: 1)
    assert_equal({path: {foo_id: 1}}, specifieds.params)
    specifieds.all
    assert_equal({path: {foo_id: 1}}, specifieds.params)
  end

  def test_nested_create
    stub_request(:post, "http://example.com/foos/1/specifieds")
      .to_return(headers: {
        content_type: "application/vnd.api+json"
      }, body: {
        data: {
          id: 1,
          name: "Jeff Ching",
          bars: [{id: 1, attributes: {address: "123 Main St."}}]
        }
      }.to_json)

    specified = Specified.create(foo_id: 1)
  end

end
