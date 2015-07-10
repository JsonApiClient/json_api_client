require 'test_helper'

class PersistenceTest < MiniTest::Test

  def test_standard_primary_key
    user = User.new
    assert !user.persisted?

    user = User.new(id: 1234)
    assert !user.persisted?

    user = User.load(id: 1234)
    assert user.persisted?
  end

  def test_non_standard_primary_key
    user_preference = UserPreference.new(id: 1234)
    assert !user_preference.persisted?

    user_preference = UserPreference.new(user_id: 1234)
    assert !user_preference.persisted?

    user_preference = UserPreference.load(user_id: 1234)
    assert user_preference.persisted?
  end

  def test_finding
    stub_request(:get, "http://example.com/users")
      .to_return(headers: {content_type: "application/vnd.api+json"}, body: {
        data: [
          {id: 1, name: "Jeff Ching", email_address: "ching.jeff@gmail.com"},
          {id: 2, name: "Barry Bonds", email_address: "barry@bonds.com"},
          {id: 3, name: "Hank Aaron", email_address: "hank@aaron.com"}
        ]
      }.to_json)

    User.all.each do |user|
      assert user.persisted?
    end
  end

  def test_included_data_should_also_be_persisted
    stub_request(:get, "http://example.com/articles")
      .to_return(headers: {content_type: "application/vnd.api+json"}, body: {
        data: [{
          type: "articles",
          id: "1",
          attributes: {
            title: "JSON API paints my bikeshed!"
          },
          relationships: {
            comments: {
              data: [
                {type: "comments", id: "17"},
                {type: "comments", id: "18"},
              ]
            }
          }
        }],
        included: [{
          type: "comments",
          id: "17",
          attributes: {
            body: "I like this post a lot!"
          }
        },{
          type: "comments",
          id: "18",
          attributes: {
            body: "This article is terrible..."
          }
        }]
      }.to_json)

    articles = Article.all
    article = articles.first
    comments = article.comments
    assert_equal 2, comments.length
    comments.each do |comment|
      assert comment.persisted?, "included records should be persisted?"
    end
  end

end
