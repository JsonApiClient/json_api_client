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

class Shallowed < TestResource
  belongs_to :foo, class_name: "Property", shallow_path: true
end

class PrefixedOwner < TestResource
  has_many :prefixed_properties
end

class PrefixedProperty < TestResource
  has_one :prefixed_owner
end

module Namespaced
  class Owner < TestResource
    has_many :properties
  end

  class Property < TestResource
    belongs_to :owner
  end
end

class Formatted < TestResource
  def self.key_formatter
    JsonApiClient::DasherizedKeyFormatter
  end

  def self.route_formatter
    JsonApiClient::DasherizedRouteFormatter
  end
end

class MultiWordParent < Formatted
end

class MultiWordChild < Formatted
  belongs_to :multi_word_parent
  self.read_only_attributes = read_only_attributes + [:multi_word_parent_id]

  def self.key_formatter
    JsonApiClient::DasherizedKeyFormatter
  end

  def self.route_formatter
    JsonApiClient::UnderscoredKeyFormatter
  end
end

class Account < TestResource
  property :name
  property :is_active, default: true
  property :balance
end

class UserAccount < TestResource
  self.add_defaults_to_changes = true
  property :name
  property :is_active, default: true
  property :balance
end

class Employee < TestResource
  has_one :chief, klass: 'Employee'
end

class AssociationTest < MiniTest::Test
  def test_default_properties_no_changes
    stub_request(:post, 'http://example.com/accounts').
        with(headers: { content_type: 'application/vnd.api+json', accept: 'application/vnd.api+json' }, body: {
            data: {
                type: 'accounts',
                attributes: {
                    name: 'foo'
                }
            }
        }.to_json)
        .to_return(headers: { content_type: 'application/vnd.api+json' }, body: {
            data: {
                id: '1',
                type: 'accounts',
                attributes: {
                    name: 'foo',
                    is_active: false,
                    balance: '0.0'
                }
            }
        }.to_json)
    record = Account.new(name: 'foo')
    assert record.save
    assert_equal(false, record.is_active)
    assert_equal('0.0', record.balance)
  end

  def test_default_properties_changes
    stub_request(:post, 'http://example.com/user_accounts').
        with(headers: { content_type: 'application/vnd.api+json', accept: 'application/vnd.api+json' }, body: {
            data: {
                type: 'user_accounts',
                attributes: {
                    name: 'foo',
                    is_active: true
                }
            }
        }.to_json)
        .to_return(headers: { content_type: 'application/vnd.api+json' }, body: {
            data: {
                id: '1',
                type: 'user_accounts',
                attributes: {
                    name: 'foo',
                    is_active: true,
                    balance: '0.0'
                }
            }
        }.to_json)
    record = UserAccount.new(name: 'foo')
    assert record.save
    assert_equal(true, record.is_active)
    assert_equal('0.0', record.balance)
  end

  def test_belongs_to_urls_are_formatted
    request = stub_request(:get, "http://example.com/multi_word_parents/1/multi_word_children")
      .to_return(headers: {content_type: "application/vnd.api+json"}, body: { data: [] }.to_json)

    MultiWordChild.where(multi_word_parent_id: 1).to_a

    assert_requested(request)
  end

  def test_belongs_to_urls_create_record
    stub_request(:post, 'http://example.com/multi_word_parents/1/multi_word_children').
        with(headers: { content_type: 'application/vnd.api+json', accept: 'application/vnd.api+json' }, body: {
            data: {
                type: 'multi_word_children',
                attributes: {
                    foo: 'bar',
                    'multi-word-field': true
                }
            }
        }.to_json)
        .to_return(headers: { content_type: 'application/vnd.api+json' }, body: {
            data: {
                    id: '2',
                    type: 'multi_word_children',
                    attributes: {
                        foo: 'bar',
                        'multi-word-field': true
                    }
                }
        }.to_json)

    record = MultiWordChild.new(multi_word_parent_id: 1, foo: 'bar', multi_word_field: true)
    result = record.save
    assert result
    assert_equal('2', record.id)
  end

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

  def test_has_one_loads_nil
    stub_request(:get, "http://example.com/properties/1")
      .to_return(headers: {content_type: "application/vnd.api+json"}, body: {
        data: [
          {
            id: 1,
            type: "addresses",
            attributes: {
              address: "123 Main St."
            }
          }
        ]
      }.to_json)

    property = Property.find(1).first
    assert_nil property.owner, "expected to be able to ask for explicitly declared association even if it's not present"
  end

  def test_has_one_fetches_relationship
    stub_request(:get, "http://example.com/properties/1")
      .to_return(headers: {content_type: "application/vnd.api+json"}, body: {
        data: [
          {
            id: 1,
            type: "addresses",
            attributes: {
              address: "123 Main St."
            },
            relationships: {
              owner: {
                links: {
                  self: 'http://example.com/properties/1/links/owner',
                  related: 'http://example.com/owners/1'
                }
              }
            }
          }
        ]
      }.to_json)
    stub_request(:get, "http://example.com/owners/1")
      .to_return(headers: {content_type: "application/vnd.api+json"}, body: {
        data: [
          {
            id: 1,
            type: "owner",
            attributes: {
              name: "Jeff Ching"
            }
          }
        ]
      }.to_json)

    property = Property.find(1).first
    owner = property.owner
    assert owner, "expected to be able to fetch relationship if defined"
    assert_equal Owner, owner.class
  end

  def test_has_many_fetches_relationship
    stub_request(:get, "http://example.com/owners/1")
      .to_return(headers: {content_type: "application/vnd.api+json"}, body: {
        data: [
          {
            id: 1,
            attributes: {
              name: "Jeff Ching",
            },
            relationships: {
              properties: {
                links: {
                  self: 'http://example.com/owners/1/links/properties',
                  related: 'http://example.com/owners/1/properties'
                }
              }
            }
          }
        ]
      }.to_json)
    stub_request(:get, "http://example.com/owners/1/properties")
      .to_return(headers: {content_type: "application/vnd.api+json"}, body: {
        data: [
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
    owner = Owner.find(1).first
    properties_query_builder = owner.properties
    properties = properties_query_builder.to_a
    assert_equal(JsonApiClient::Query::Builder, properties_query_builder.class)
    assert_equal(Property, properties_query_builder.klass)
    assert_equal(JsonApiClient::Query::Requestor, properties_query_builder.requestor.class)
    assert_equal(JsonApiClient::ResultSet, properties.class)
    assert_equal("314 150th Ave", properties.last.address)
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

  def test_load_has_many_with_multiword_resource_name
    stub_request(:get, "http://example.com/prefixed_owners?include=prefixed_properties")
      .to_return(headers: {content_type: "application/vnd.api+json"}, body: {
        data: [
          {
            id: 1,
            attributes: {
              name: "Jeff Ching",
            },
            relationships: {
              prefixed_properties: {
                data: [
                  {id: 1, type: 'prefixed_property'},
                  {id: 2, type: 'prefixed_property'}
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
              prefixed_properties: {
                data: [
                  {id: 3, type: 'prefixed_property'}
                ]
              }
            }
          }
        ],
        included: [
          {
            id: 1,
            type: 'prefixed_property',
            attributes: {address: "123 Main St."}
          },
          {
            id: 2,
            type: 'prefixed_property',
            attributes: {address: "223 Elm St."}
          },
          {
            id: 3,
            type: 'prefixed_property',
            attributes: {address: "314 150th Ave"}
          }
        ]
      }.to_json)
    owners = PrefixedOwner.includes(:prefixed_properties).all
    jeff = owners[0]
    assert_equal("Jeff Ching", jeff.name)
    assert_equal(2, jeff.prefixed_properties.length)
    assert_equal(PrefixedProperty, jeff.prefixed_properties.first.class)
    assert_equal("123 Main St.", jeff.prefixed_properties.first.address)
  end

  def test_load_has_many_with_configurable_multiword_resource_name_and_type
    with_altered_config(PrefixedOwner, :json_key_format => :camelized_key,
      :route_format => :dasherized_route) do

      stub_request(:get, "http://example.com/prefixed-owners?include=prefixed-properties")
        .to_return(headers: {content_type: "application/vnd.api+json"}, body: {
          data: [
            {
              id: 1,
              attributes: {
                name: "Jeff Ching",
              },
              relationships: {
                prefixedProperties: {
                  data: [
                    {id: 1, type: 'prefixed-property'},
                    {id: 2, type: 'prefixed-property'}
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
                prefixedProperties: {
                  data: [
                    {id: 3, type: 'prefixed-property'}
                  ]
                }
              }
            }
          ],
          included: [
            {
              id: 1,
              type: 'prefixed-property',
              attributes: {address: "123 Main St."}
            },
            {
              id: 2,
              type: 'prefixed-property',
              attributes: {address: "223 Elm St."}
            },
            {
              id: 3,
              type: 'prefixed-property',
              attributes: {address: "314 150th Ave"}
            }
          ]
        }.to_json)
      owners = PrefixedOwner.includes("prefixed-properties").all
      jeff = owners[0]
      assert_equal("Jeff Ching", jeff.name)
      assert_equal(2, jeff.prefixed_properties.length)
      assert_equal(PrefixedProperty, jeff.prefixed_properties.first.class)
      assert_equal("123 Main St.", jeff.prefixed_properties.first.address)
    end
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

  def test_respect_included_has_many_relationship_empty_data
    stub_request(:get, "http://example.com/owners/1?include=properties")
      .to_return(headers: {content_type: "application/vnd.api+json"}, body: {
        data: [
          {
            id: 1,
            attributes: {name: "Jeff Ching"},
            relationships: {
              properties: {
                links: {
                  self: "http://example.com/owners/1/relationships/properties",
                  related: "http://example.com/owners/1/properties"
                },
                data: []
              }
            }
          }
        ]
      }.to_json)

    owner = Owner.includes('properties').find(1).first
    assert_equal(0, owner.properties.length)
  end

  def test_respect_included_has_one_relationship_null_data
    stub_request(:get, "http://example.com/properties/1?include=owner")
      .to_return(headers: {content_type: "application/vnd.api+json"}, body: {
        data: [
          {
            id: 1,
            type: "properties",
            attributes: {address: "123 Main St."},
            relationships: {
              owner: {
                links: {
                  self: "http://example.com/properties/1/relationships/owner",
                  related: "http://example.com/properties/1/owner"
                },
                data: nil
              }
            }
          }
        ]
      }.to_json)

    property = Property.includes('owner').find(1).first

    assert_nil(property.owner)
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
    assert_raises ArgumentError do
      Specified.path({})
    end
    assert_equal("foos/%{foo_id}/specifieds", Specified.path)
    assert_equal("foos/1/specifieds", Specified.path({foo_id: 1}))
    assert_equal("foos/%D0%99%D0%A6%D0%A3%D0%9A%D0%95%D0%9D/specifieds", Specified.path({foo_id: 'ЙЦУКЕН'}))
  end

  def test_belongs_to_shallowed_path
    assert_equal([:foo_id], Shallowed.prefix_params)
    assert_equal "shalloweds", Shallowed.path({})
    assert_equal("foos/%{foo_id}/shalloweds", Shallowed.path)
    assert_equal("foos/1/shalloweds", Shallowed.path({foo_id: 1}))
    assert_equal("foos/%D0%99%D0%A6%D0%A3%D0%9A%D0%95%D0%9D/shalloweds", Shallowed.path({foo_id: 'ЙЦУКЕН'}))
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

  def test_find_belongs_to_shallowed
    stub_request(:get, "http://example.com/foos/1/shalloweds")
        .to_return(headers: {content_type: "application/vnd.api+json"}, body: {
            data: [
                { id: 1, type: "shalloweds", attributes: { name: "nested" } }
            ]
        }.to_json)

    stub_request(:get, "http://example.com/shalloweds")
        .to_return(headers: {content_type: "application/vnd.api+json"}, body: {
            data: [
                { id: 1, type: "shalloweds", attributes: { name: "global" } }
            ]
        }.to_json)

    nested_records = Shallowed.where(foo_id: 1).all
    assert_equal(1, nested_records.length)
    assert_equal("nested", nested_records.first.name)

    global_records = Shallowed.all
    assert_equal(1, global_records.length)
    assert_equal("global", global_records.first.name)
  end

  def test_can_handle_creating
    stub_request(:post, "http://example.com/foos/10/specifieds")
      .to_return(headers: {content_type: "application/vnd.api+json"}, body: {
        data: [
          {id: 12, attributes: {name: "Blah"}}
        ]
      }.to_json)

    Specified.create({
      :id => 12,
      :foo_id => 10,
      :name => "Blah"
    })
  end

  def test_can_handle_creating_shallowed
    stub_request(:post, "http://example.com/foos/10/shalloweds")
        .to_return(headers: {content_type: "application/vnd.api+json"}, body: {
            data: { id: 12, type: "shalloweds", attributes: { name: "nested" } }
        }.to_json)

    stub_request(:post, "http://example.com/shalloweds")
        .to_return(headers: {content_type: "application/vnd.api+json"}, body: {
            data: { id: 13, type: "shalloweds", attributes: { name: "global" } }
        }.to_json)

    Shallowed.create({
                         :id => 12,
                         :foo_id => 10,
                         :name => "nested"
                     })
    Shallowed.create({
                         :id => 13,
                         :name => "global"
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

    Specified.create(foo_id: 1)
  end

  def test_nested_create_from_scope
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

    Specified.where(foo_id: 1).create
  end

  def test_get_with_relationship_for_model_with_custom_type
    stub_request(:get, "http://example.com/document_users/1?include=file")
        .to_return(headers: {content_type: "application/vnd.api+json"}, body: {
            data: [
                {
                    id: '1',
                    type: 'document_users',
                    attributes: {
                        name: 'John Doe'
                    },
                    relationships: {
                        file: {
                            links: {
                                self: 'http://example.com/document_users/1/relationships/file',
                                related: 'http://example.com/document_users/1/file'
                            },
                            data: {
                                id: '2',
                                type: 'document--files'
                            }
                        }
                    }
                }
            ],
            included: [
                {
                    id: '2',
                    type: 'document--files',
                    attributes: {
                        url: 'http://example.com/downloads/2.pdf'
                    }
                }
            ]
        }.to_json)

    user = DocumentUser.includes('file').find(1).first

    assert_equal 'document--files', user.file.type
    assert user.file.is_a?(DocumentFile)
  end

  def test_get_with_defined_relationship_for_model_with_custom_type
    stub_request(:get, "http://example.com/document_stores/1?include=files")
        .to_return(headers: {content_type: "application/vnd.api+json"}, body: {
            data: [
                {
                    id: '1',
                    type: 'document_stores',
                    attributes: {
                        name: 'store #1'
                    },
                    relationships: {
                        files: {
                            links: {
                                self: 'http://example.com/document_stores/1/relationships/files',
                                related: 'http://example.com/document_stores/1/files'
                            },
                            data: [
                                {
                                    id: '2',
                                    type: 'document--files'
                                }
                            ]
                        }
                    }
                }
            ],
            included: [
                {
                    id: '2',
                    type: 'document--files',
                    attributes: {
                        url: 'http://example.com/downloads/2.pdf'
                    }
                }
            ]
        }.to_json)

    user = DocumentStore.includes('files').find(1).first

    assert_equal 1, user.files.size
    assert_equal 'document--files', user.files.first.type
    assert user.files.first.is_a?(DocumentFile)
  end

  def test_get_with_type_attribute
    stub_request(:get, "http://example.com/document_users/1?include=file")
        .to_return(headers: {content_type: "application/vnd.api+json"}, body: {
            data: [
                {
                    id: '1',
                    type: 'document_users',
                    attributes: {
                        name: 'John Doe'
                    },
                    relationships: {
                        file: {
                            links: {
                                self: 'http://example.com/document_users/1/relationships/file',
                                related: 'http://example.com/document_users/1/file'
                            },
                            data: {
                                id: '2',
                                type: 'document--files'
                            }
                        }
                    }
                }
            ],
            included: [
                {
                    id: '2',
                    type: 'document--files',
                    attributes: {
                        type: 'STIDocumentFile',
                        url: 'http://example.com/downloads/2.pdf'
                    }
                }
            ]
        }.to_json)

    user = DocumentUser.includes('file').find(1).first

    assert_equal 'STIDocumentFile', user.file.type
    assert user.file.is_a?(DocumentFile)
  end

  def test_include_with_blank_relationships
    stub_request(:get, "http://example.com/document_users/1?include=file")
        .to_return(headers: {content_type: "application/vnd.api+json"}, body: {
            data: [
                {
                    id: '1',
                    type: 'document_users',
                    attributes: {
                        name: 'John Doe'
                    },
                    relationships: {
                        file: {
                        }
                    }
                }
            ],
        }.to_json)

    user = DocumentUser.includes('file').find(1).first
    assert_nil user.file
  end

  def test_load_include_from_dataset
    stub_request(:get, 'http://example.com/employees?include=chief&page[per_page]=2')
        .to_return(
            headers: {
                content_type: 'application/vnd.api+json'
            }, body: {
            data: [
                {
                    id: '1',
                    type: 'employees',
                    attributes: {
                        name: 'John Doe'
                    },
                    relationships: {
                        chief: {
                            data: {id: '2', type: 'employees'}
                        }
                    }
                },
                {
                    id: '2',
                    attributes: {
                        name: 'Jane Doe'
                    },
                    relationships: {
                        chief: {
                            data: {id: '3', type: 'employees'}
                        }
                    }
                }
            ],
            included: [
                {
                    id: '3',
                    type: 'employees',
                    attributes: {
                        name: 'Richard Reed'
                    }
                }
            ]
        }.to_json)
    Employee.search_included_in_result_set = true
    records = Employee.includes(:chief).per(2).to_a
    assert_equal(2, records.size)
    assert_equal('1', records.first.id)
    assert_equal('2', records.second.id)
    assert_equal('3', records.second.chief.id)
    assert_equal('2', records.first.chief.id)
  end

  def test_does_not_load_include_from_dataset
    stub_request(:get, 'http://example.com/employees?include=chief&page[per_page]=2')
        .to_return(
            headers: {
                content_type: 'application/vnd.api+json'
            }, body: {
            data: [
                {
                    id: '1',
                    type: 'employees',
                    attributes: {
                        name: 'John Doe'
                    },
                    relationships: {
                        chief: {
                            data: {id: '2', type: 'employees'}
                        }
                    }
                },
                {
                    id: '2',
                    attributes: {
                        name: 'Jane Doe'
                    },
                    relationships: {
                        chief: {
                            data: {id: '3', type: 'employees'}
                        }
                    }
                }
            ],
            included: [
                {
                    id: '3',
                    type: 'employees',
                    attributes: {
                        name: 'Richard Reed'
                    }
                }
            ]
        }.to_json)
    Employee.search_included_in_result_set = false
    records = Employee.includes(:chief).per(2).to_a
    assert_equal(2, records.size)
    assert_equal('1', records.first.id)
    assert_equal('2', records.second.id)
    assert_equal('3', records.second.chief.id)
    assert_nil(records.first.chief)
  end

end
