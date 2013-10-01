require 'test_helper'

class User < JsonApiClient::Resource
  class << self
    def site
      "http://localhost:3000/api/1"
    end
  end
end

class UserTest < ResourceTest
  RESOURCE = "http://localhost:3000/api/1/users"

  def setup
    super
    # VCR.insert_cassette 'users', record: :new_episodes
  end

  def teardown
    # VCR.eject_cassette
    super
  end

  def test_basic
    assert User.is_a?(Class)
  end

  def test_endpoint
    assert_equal "http://localhost:3000/api/1/users", User.resource
  end

  def test_find
    assert_requested "users/1.json", :get, {}, [{id: 1, name: "Jeff Ching", email_address: "ching.jeff@gmail.com"}]
    user = User.find(1)
    assert_equal 1, user.id
    assert_equal "ching.jeff@gmail.com", user.email_address
    assert_equal "Jeff Ching", user.name
  end

  def test_find_by_ids
    assert_requested "users.json", :get, {id: [2,3]}, [
      {id: 2, name: "Barry Bonds", email_address: "barry@bonds.com"},
      {id: 3, name: "Hank Aaron", email_address: "hank@aaron.com"}
    ]
    users = User.find([2,3])
    assert_equal 2, users.length
    assert_equal [2,3], users.map(&:id)
  end

  def test_find_all
    assert_requested "users.json", :get, {}, [
      {id: 1, name: "Jeff Ching", email_address: "ching.jeff@gmail.com"},
      {id: 2, name: "Barry Bonds", email_address: "barry@bonds.com"},
      {id: 3, name: "Hank Aaron", email_address: "hank@aaron.com"}
    ]
    users = User.all
    assert users.length > 0
  end

  def test_find_all_with_scope
    assert_requested "users.json", :get, {name: "Jeff Ching"}, [
      {id: 1, name: "Jeff Ching", email_address: "ching.jeff@gmail.com"}
    ]
    users = User.where(name: "Jeff Ching").all
    assert_equal 1, users.length
  end

  def test_create
    assert_requested "users.json", :post, {name: "Mickey Mantle", email_address: "mickey@mantle.com"}, [
      {id: 3, name: "Mickey Mantle", email_address: "mickey@mantle.com"}
    ]
    user = User.create(
      name: "Mickey Mantle",
      email_address: "mickey@mantle.com"
    )
    assert_equal 3, user.id
  end

end