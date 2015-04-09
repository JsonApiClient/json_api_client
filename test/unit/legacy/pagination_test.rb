require 'test_helper'

class PaginationTest < MiniTest::Unit::TestCase

  def test_no_meta_data
    stub_request(:get, "http://localhost:3000/api/1/users.json")
      .to_return(headers: {content_type: "application/json"}, body: {
        users: [
          {id: 1, name: "Jeff Ching", email_address: "ching.jeff@gmail.com"},
          {id: 2, name: "Barry Bonds", email_address: "barry@bonds.com"},
          {id: 3, name: "Hank Aaron", email_address: "hank@aaron.com"}
        ]
      }.to_json)

    users = User.all
    assert_equal 3, users.length
    assert_equal 3, users.per_page
    assert_equal 1, users.current_page
    assert_equal 0, users.offset
    assert_equal 3, users.total_entries
    assert_equal 1, users.total_pages
  end

  def test_meta_data
    stub_request(:get, "http://localhost:3000/api/1/users.json")
      .to_return(headers: {content_type: "application/json"}, body: {
        users: [
          {id: 1, name: "Jeff Ching", email_address: "ching.jeff@gmail.com"},
          {id: 2, name: "Barry Bonds", email_address: "barry@bonds.com"},
          {id: 3, name: "Hank Aaron", email_address: "hank@aaron.com"}
        ],
        meta: {
          per_page: 3,
          current_page: 2,
          offset: 3,
          total_entries: 10,
          total_pages: 4
        }
      }.to_json)

    users = User.all
    assert_equal 3, users.length
    assert_equal 3, users.per_page
    assert_equal 2, users.current_page
    assert_equal 3, users.offset
    assert_equal 10, users.total_entries
    assert_equal 4, users.total_pages
  end

  def test_custom_meta_data
    stub_request(:get, "http://localhost:3000/api/1/custom_paginations.json")
    .to_return(headers: {content_type: "application/json"}, body: {
      custom_paginations: [
        {id: 1, name: "Jeff Ching", email_address: "ching.jeff@gmail.com"},
        {id: 2, name: "Barry Bonds", email_address: "barry@bonds.com"},
        {id: 3, name: "Hank Aaron", email_address: "hank@aaron.com"}
      ],
      meta: {
        per: 3,
        page: 2,
        total: 10
      }
    }.to_json)

    users = CustomPagination.all
    assert_equal 3, users.length
    assert_equal 3, users.per_page
    assert_equal 2, users.current_page
    assert_equal 3, users.offset
    assert_equal 10, users.total_entries
    assert_equal 4, users.total_pages
  end

  # will_paginate gem specific parameters check
  # https://github.com/mislav/will_paginate/blob/master/lib/will_paginate/collection.rb
  def test_will_paginate_params
    stub_request(:get, "http://localhost:3000/api/1/custom_paginations.json")
    .to_return(headers: {content_type: "application/json"}, body: {
      custom_paginations: [
        {id: 1, name: "Jeff Ching", email_address: "ching.jeff@gmail.com"},
        {id: 2, name: "Barry Bonds", email_address: "barry@bonds.com"},
        {id: 3, name: "Hank Aaron", email_address: "hank@aaron.com"}
      ],
      meta: {
        per: 3,
        page: 2,
        total: 10
      }
    }.to_json)

    users = CustomPagination.all
    assert_equal 4, users.total_pages
    assert_equal 3, users.offset
    assert_equal 1, users.previous_page
    assert_equal 3, users.next_page
    assert_equal false, users.out_of_bounds?
    assert_equal 2, users.current_page
    assert_equal 10, users.total_entries
    assert_equal 3, users.per_page
  end

  # kaminari gem specific parameters check
  # https://github.com/amatsuda/kaminari/blob/master/lib/kaminari/models/array_extension.rb
  def test_kaminari_params
    stub_request(:get, "http://localhost:3000/api/1/custom_paginations.json")
    .to_return(headers: {content_type: "application/json"}, body: {
      custom_paginations: [
        {id: 1, name: "Jeff Ching", email_address: "ching.jeff@gmail.com"},
        {id: 2, name: "Barry Bonds", email_address: "barry@bonds.com"},
        {id: 3, name: "Hank Aaron", email_address: "hank@aaron.com"}
      ],
      meta: {
        per: 3,
        page: 2,
        total: 10
      }
    }.to_json)

    users = CustomPagination.all
    assert_equal 3, users.limit_value
    assert_equal 1, users.previous_page
    assert_equal 3, users.next_page
    assert_equal 2, users.current_page
    assert_equal 10, users.total_entries
    assert_equal 3, users.per_page
  end

  def test_can_handle_page_param
    stub_request(:get, "http://localhost:3000/api/1/users.json")
    .to_return(headers: {content_type: "application/json"}, body: {
      users: [
        {id: 1, name: "Jeff Ching", email_address: "ching.jeff@gmail.com"},
        {id: 2, name: "Barry Bonds", email_address: "barry@bonds.com"},
        {id: 3, name: "Hank Aaron", email_address: "hank@aaron.com"}
      ],
      meta: {
        per_page: 3,
        page: 2,
        offset: 3,
        total_entries: 10,
        total_pages: 4
      }
    }.to_json)

    users = User.all
    assert_equal 3, users.length
    assert_equal 3, users.per_page
    assert_equal 2, users.current_page
    assert_equal 3, users.offset
    assert_equal 10, users.total_entries
    assert_equal 4, users.total_pages
  end

end