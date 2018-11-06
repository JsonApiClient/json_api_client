require 'test_helper'

class CreationWithRelationTest < MiniTest::Test
  def test_create_with_relationships_in_payload
    stub_request(:post, 'http://example.com/articles')
        .with(headers: {content_type: 'application/vnd.api+json', accept: 'application/vnd.api+json'}, body: {
            data: {
                type: 'articles',
                attributes: {
                    title: 'Rails is Omakase'
                },
                relationships: {
                    comments: {
                        data: [
                            {
                                id: '2',
                                type: 'comments'
                            }
                        ]
                    }
                }
            }
        }.to_json)
        .to_return(headers: {content_type: 'application/vnd.api+json'}, body: {
            data: {
                type: 'articles',
                id: '1',
                attributes: {
                    title: 'Rails is Omakase'
                }
            }
        }.to_json)

    article = Article.new(title: 'Rails is Omakase', relationships: {comments: [Comment.new(id: 2)]})

    assert article.save
    assert article.persisted?
    assert_equal "1", article.id
  end
end
