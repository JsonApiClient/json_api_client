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
    assert_equal 2, article.errors.size

    assert_equal ["Email address is invalid."], article.errors[:email_address]
    assert_equal ["Title already taken"], article.errors[:base]

    error = article.last_result_set.errors.first
    assert_equal "1234-abcd", error.id
    assert_equal "http://example.com/help/errors/1337", error.about
    assert_equal "400", error.status
    assert_equal "1337", error.code
    assert_equal "Email address is invalid.", error.title
    assert_equal "Email address 'bar' is not a valid email address.", error.detail
    assert_equal "/data/attributes/email_address", error.source_pointer
    assert_nil error.source_parameter
    assert error.meta.is_a?(JsonApiClient::MetaData)
    assert_equal "asdf", error.meta.qwer

    error = article.last_result_set.errors.last
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

  def test_can_handle_generic_error
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
                    status: "422",
                    code: "1337",
                    title: "You can't create this record",
                    detail: "You can't create this record",
                    source: {
                        pointer: "/data"
                    }
                }
            ]
        }.to_json)

    article = Article.create({
                                 title: "Rails is Omakase",
                                 email_address: "bar"
                             })
    refute article.persisted?
    assert article.errors.present?
    assert_equal 1, article.errors.size

    assert_equal ["You can't create this record"], article.errors[:base]

    error = article.last_result_set.errors.first
    assert_equal "1234-abcd", error.id
    assert_nil error.about
    assert_equal "422", error.status
    assert_equal "1337", error.code
    assert_equal "You can't create this record", error.title
    assert_equal "You can't create this record", error.detail
    assert_equal "/data", error.source_pointer
    assert_nil error.source_parameter
  end

  def test_can_handle_parameter_error
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
                    status: "400",
                    code: "1337",
                    title: "bar is required",
                    detail: "bar include is required for creation",
                    source: {
                        parameter: "include"
                    }
                }
            ]
        }.to_json)

    article = Article.create({
                                 title: "Rails is Omakase",
                                 email_address: "bar"
                             })
    refute article.persisted?
    assert article.errors.present?
    assert_equal 1, article.errors.size

    assert_equal ["include bar is required"], article.errors[:base]

    error = article.last_result_set.errors.first
    assert_equal "1234-abcd", error.id
    assert_nil error.about
    assert_equal "400", error.status
    assert_equal "1337", error.code
    assert_equal "bar is required", error.title
    assert_equal "bar include is required for creation", error.detail
    assert_nil error.source_pointer
    assert_equal "include", error.source_parameter
  end

  def test_can_handle_explicit_null_error_values
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
              id: "1337",
              links: nil,
              status: nil,
              code: nil,
              title: nil,
              detail: nil,
              source: nil,
              meta: nil
            }
          ]
        }.to_json)

      article = Article.create({
        title: "Rails is Omakase",
        email_address: "bar"
      })
      assert !article.persisted?
      assert article.errors.present?
      assert_equal 1, article.errors.size

      assert_equal ["invalid"], article.errors[:base]

      error = article.last_result_set.errors.first
      assert_equal "1337", error.id

      assert_equal({}, error.about, nil)
      assert_nil(error.status, nil)
      assert_nil(error.code, nil)
      assert_nil(error.title, nil)
      assert_nil(error.detail, nil)
      assert_equal({}, error.source, nil)
      assert_equal({}, error.meta.attributes,nil)
  end

end
