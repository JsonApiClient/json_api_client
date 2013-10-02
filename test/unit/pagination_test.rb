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

end