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
        links: {
          "user.posts" => {
            href: 'http://localhost:3000/api/1/posts/{user.posts}',
            type: "posts"
          },
          "user.address" => {
            href: 'http://localhost:3000/api/1/addresses/{user.address}',
            type: "addresses"
          }
        }
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
          {id: 4, address: "1st Ave S"}
        ]
      }.to_json)

    user = User.find(1).first
    assert(user)
    assert user.respond_to?(:posts), "should load link for posts"

    posts = user.posts
    assert_equal 2, posts.length
    posts.each do |post|
      assert post.is_a?(Post), "should figure out what type of object for Post"
    end

    assert user.respond_to?(:address), "should load link for address"
    address = user.address
    assert_equal 1, address.length
    assert address.first.is_a?(Address), "should figure out what type of object for Address"
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
        links: {
          "user.posts" => {
            href: 'http://localhost:3000/api/1/posts/{user.posts}',
            type: "posts"
          },
          "user.address" => {
            href: 'http://localhost:3000/api/1/addresses/{user.address}',
            type: "addresses"
          },
          "address.state" => {
            href: 'http://localhost:3000/api/1/states/{address.state}',
            type: "states"
          }
        },
        linked: {
          addresses: [
            {
              id: 4, address: "1st Ave S", state_id: 1,
              links: {
                "state": 1
              }
            }
          ],
          posts: [
            {id: 2, title: "Yo", body: "Lo"},
            {id: 3, title: "Foo", body: "Bar"}
          ],
          states: [
            {id: 1, name: "Washington"}
          ]
        }
      }.to_json)

    user = User.find(1).first
    assert(user)
    assert user.respond_to?(:posts), "should load link for posts"

    posts = user.posts
    assert_equal 2, posts.length
    posts.each do |post|
      assert post.is_a?(Post), "should figure out what type of object for Post"
    end

    assert user.respond_to?(:address), "should load link for address"
    address = user.address
    assert_equal 1, address.length
    assert address.first.is_a?(Address), "should figure out what type of object for Address"

    assert address.first.respond_to?(:state), "expected deep-linked state to be available"
    state = address.first.state.first
    assert state.is_a?(State), "should figure out what type of object for State"
    assert_equal "Washington", state.name, "should load data from linked section for state"
  end

end
