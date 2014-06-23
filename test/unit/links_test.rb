require 'test_helper'

class LinksTest < MiniTest::Unit::TestCase

  def test_can_make_requests_for_data_if_linked_data_not_provided
    stub_request(:get, "http://localhost:3000/api/1/users/1.json")
      .to_return(headers: {content_type: "application/json"}, body: {
        users: [
          {id: 1, name: "Jeff Ching", email_address: "ching.jeff@gmail.com", links: {
            posts: [2,3],
            address: 4
          }}
        ],
        links: [
          "user.posts" => {
            href: 'http://localhost:3000/api/1/posts/#{user.posts}',
            type: "posts"
          },
          "user.address" => {
            href: 'http://localhost:3000/api/1/addresses/#{user.address}',
            type: "addresses"
          }
        ]
      }.to_json)
    stub_request(:get, "http://localhost:3000/api/1/posts/2,3.json")
      .to_return(headers: {content_type: "application/json"}, body: {
        posts: [
          {id: 2, title: "Yo", body: "Lo"},
          {id: 3, title: "Foo", body: "Bar"}
        ]
      }.to_json)
    stub_request(:get, "http://localhost:3000/api/1/addresses/4.json")
      .to_return(headers: {content_type: "application/json"}, body: {
        addresses: [
          {id: 5, address: "1st Ave S"}
        ]
      }.to_json)

    user = User.find(1).first
    assert(user)
    assert user.respond_to?(:posts), "should load link for posts"
    assert_equl 2, user.posts.length

    assert user.respond_to?(:address), "should load link for address"
    assert_equal 1, user.address.length
  end

  def test_can_load_linked_data
    stub_request(:get, "http://localhost:3000/api/1/users/1.json")
      .to_return(headers: {content_type: "application/json"}, body: {
        users: [
          {id: 1, name: "Jeff Ching", email_address: "ching.jeff@gmail.com", links: {
            posts: [2,3],
            address: 4
          }}
        ],
        links: [
          "user.posts" => {
            href: 'http://localhost:3000/api/1/posts/#{user.posts}',
            type: "posts"
          },
          "user.address" => {
            href: 'http://localhost:3000/api/1/addresses/#{user.address}',
            type: "addresses"
          }
        ],
        linked: {
          addresses: [
            {id: 5, address: "1st Ave S"}
          ],
          posts: [
            {id: 2, title: "Yo", body: "Lo"},
            {id: 3, title: "Foo", body: "Bar"}
          ]
        }
      }.to_json)

    user = User.find(1).first
    assert(user)
    assert user.respond_to?(:posts), "should load link for posts"
    assert_equl 2, user.posts.length

    assert user.respond_to?(:address), "should load link for address"
    assert_equal 1, user.address.length
  end

end