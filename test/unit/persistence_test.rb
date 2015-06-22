require 'test_helper'

class PersistenceTest < MiniTest::Unit::TestCase

  def test_standard_primary_key
    user = User.new
    assert !user.persisted?

    user = User.new(id: 1234)
    assert user.persisted?
  end

  def test_non_standard_primary_key
    user_preference = UserPreference.new(id: 1234)
    assert !user_preference.persisted?

    user_preference = UserPreference.new(user_id: 1234)
    assert user_preference.persisted?
  end

  def test_nil_primary_key
    user = User.new(id: nil)
    assert !user.persisted?
  end

  def test_finding
    stub_request(:get, "http://localhost:3000/api/1/users.json")
      .to_return(headers: {content_type: "application/json"}, body: {
        users: [
          {id: 1, name: "Jeff Ching", email_address: "ching.jeff@gmail.com"},
          {id: 2, name: "Barry Bonds", email_address: "barry@bonds.com"},
          {id: 3, name: "Hank Aaron", email_address: "hank@aaron.com"}
        ]
      }.to_json)

    User.all.each do |user|
      assert user.persisted?
    end
  end

end