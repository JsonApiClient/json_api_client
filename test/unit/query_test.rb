require 'test_helper'

class QueryTest < MiniTest::Unit::TestCase

  def test_find_query_with_params
    query = JsonApiClient::Query::Find.new(User, {foo: "bar", qwer: "asdf"})
    assert_equal :get, query.request_method
    assert_equal({foo: "bar", qwer: "asdf"}, query.params)
    assert_equal "users", query.path
  end

  def test_find_by_id
    query = JsonApiClient::Query::Find.new(User, 1)
    assert_equal :get, query.request_method
    assert_equal({}, query.params)
    assert_equal "users/1", query.path
  end

  def test_find_by_primary_keys
    query = JsonApiClient::Query::Find.new(User, [2,3])
    assert_equal :get, query.request_method
    assert_equal({ids: "2,3"}, query.params)
    assert_equal "users", query.path
  end

  def test_find_by_different_primary_keys
    assert_equal :user_id, UserPreference.primary_key
    query = JsonApiClient::Query::Find.new(UserPreference, [2,3])
    assert_equal :get, query.request_method
    assert_equal({user_ids: "2,3"}, query.params)
    assert_equal "user_preferences", query.path
  end

  def test_update_query
    user = User.new(id: 1, name: "New Name")
    query = JsonApiClient::Query::Update.new(User, user.attributes)
    assert_equal :put, query.request_method
    assert_equal({user: {name: "New Name"}}.to_json, query.params.to_json)
    assert_equal "users/1", query.path
  end

  def test_create_query
    query = JsonApiClient::Query::Create.new(User, {foo: "bar", qwer: "asdf"})
    assert_equal :post, query.request_method
    assert_equal({user: {foo: "bar", qwer: "asdf"}}.to_json, query.params.to_json)
    assert_equal "users", query.path
  end

  def test_destroy_query
    user = User.new(id: 1, name: "New Name")
    query = JsonApiClient::Query::Destroy.new(User, user.attributes)
    assert_equal :delete, query.request_method
    assert_equal nil, query.params
    assert_equal "users/1", query.path
  end

  def test_custom_member_query
    user = User.new(id: 1, name: "New Name")
    query = JsonApiClient::Query::Custom.new(User, user.attributes.merge({
      name: "verify",
      request_method: :post,
      params: {
        id: 1,
        date: 'now'
      }
    }))

    assert_equal :post, query.request_method
    assert_equal({date: 'now'}.to_json, query.params.to_json)
    assert_equal "users/1/verify", query.path
  end

  def test_custom_collection_query
    query = JsonApiClient::Query::Custom.new(User, {
      name: "verify",
      request_method: :delete,
      params: {
        date: 'now'
      }
    })

    assert_equal :delete, query.request_method
    assert_equal({date: 'now'}.to_json, query.params.to_json)
    assert_equal "users/verify", query.path
  end

  def test_query_is_inpectable
    query = JsonApiClient::Query::Create.new(User, {foo: "bar", qwer: "asdf"})
    assert(query.inspect)
  end

end
