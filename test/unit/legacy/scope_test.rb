require 'legacy_test_helper'

class ScopeTest < MiniTest::Unit::TestCase

  def test_chaining
    scope = JsonApiClient::Scope.new(User).where(a: "b", c: "d")
    assert_equal JsonApiClient::Scope, scope.class
    assert_equal({a: "b", c: "d"}, scope.params)

    scope = scope.where(e: "f")
    assert_equal JsonApiClient::Scope, scope.class
    assert_equal({a: "b", c: "d", e: "f"}, scope.params)

    scope = scope.order("name desc")
    assert_equal JsonApiClient::Scope, scope.class
    assert_equal({a: "b", c: "d", e: "f", order: "name desc"}, scope.params)

    scope = scope.paginate(per_page: 30, page: 2)
    assert_equal JsonApiClient::Scope, scope.class
    assert_equal({a: "b", c: "d", e: "f", order: "name desc", per_page: 30, page: 2}, scope.params)
  end

end