require 'test_helper'

class ErrorCollectorTest < MiniTest::Test

  def test_can_handle_no_errors
    stub_request(:post, "http://example.com/articles")
      .with(headers: {content_type: "application/vnd.api+json", accept: "application/vnd.api+json"}, body: {
          data: {
            type: "articles",
            attributes: {
              title: "Rails is Omakase"
            }
          }
        }.to_json)
      .to_return(headers: {content_type: "application/vnd.api+json"}, body: {
        data: {
          id: "1",
          type: "articles",
          attributes: {
            title: "Rails is Omakase"
          }
        }
      }.to_json)

    article = Article.create({
      title: "Rails is Omakase"
    })
    assert_equal false, article.errors.present?
    assert_equal [], article.errors["title"], "expected to be able to inspect errors that are not present and return nil"
  end

  def test_can_handle_no_content
    stub_request(:post, "http://example.com/articles")
      .with(headers: {content_type: "application/vnd.api+json", accept: "application/vnd.api+json"}, body: {
          data: {
            type: "articles",
            attributes: {
              title: "Rails is Omakase"
            }
          }
        }.to_json)
      .to_return(headers: {content_type: "application/vnd.api+json"}, body: nil)

    article = Article.create({
      title: "Rails is Omakase"
    })
    assert_equal false, article.errors.present?
    assert_equal [], article.errors["title"], "expected to be able to inspect errors that are not present and return nil"
  end

  def test_can_handle_errors
    stub_request(:post, "http://example.com/articles")
      .with(headers: {content_type: "application/vnd.api+json", accept: "application/vnd.api+json"}, body: {
          data: {
            type: "articles",
            attributes: {
              title: "Rails is Omakase",
              email_address: "bar"
            }
          }
        }.to_json)
      .to_return(headers: {content_type: "application/vnd.api+json"}, body: {
        errors: [
          {
            id: "1234-abcd",
            links: {
              about: "http://example.com/help/errors/1337"
            },
            status: "400",
            code: "1337",
            title: "Email address is invalid.",
            detail: "Email address 'bar' is not a valid email address.",
            source: {
              pointer: "/data/attributes/email_address"
            },
            meta: {
              qwer: "asdf"
            }
          },
          {
            id: "33333",
            status: "400",
            code: "1338",
            title: "Title already taken"
          }
        ]
      }.to_json)

    article = Article.create({
      title: "Rails is Omakase",
      email_address: "bar"
    })
    assert !article.persisted?
    assert article.errors.present?
    assert_equal 2, article.errors.length

    error = article.errors.first
    assert_equal "1234-abcd", error.id
    assert_equal "http://example.com/help/errors/1337", error.about
    assert_equal "400", error.status
    assert_equal "1337", error.code
    assert_equal "Email address is invalid.", error.title
    assert_equal "Email address 'bar' is not a valid email address.", error.detail
    assert_equal "/data/attributes/email_address", error.source_pointer
    assert_equal "email_address", error.source_parameter
    assert error.meta.is_a?(JsonApiClient::MetaData)
    assert_equal "asdf", error.meta.qwer

    error = article.errors.last
    assert_equal "33333", error.id
    assert_nil error.about
    assert_equal "400", error.status
    assert_equal "1338", error.code
    assert_equal "Title already taken", error.title
    assert_nil error.detail
    assert_nil error.source_pointer
    assert_nil error.source_parameter
    assert error.meta.is_a?(JsonApiClient::MetaData)
  end

end