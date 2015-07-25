require 'test_helper'

class UpdatingTest < MiniTest::Test

  class CallbackTest < TestResource
    include JsonApiClient::Helpers::Callbacks
    before_update do
      self.foo = 10
    end

    after_save :after_save_method
    def after_save_method
      self.bar = 100
    end
  end

  def setup
    super
    stub_request(:get, "http://example.com/articles/1")
      .to_return(headers: {content_type: "application/vnd.api+json"}, body: {
        data: {
          type: "articles",
          id: "1",
          attributes: {
            title: "Rails is Omakase"
          }
        }
      }.to_json)
  end

  def test_can_update_found_record
    articles = Article.find(1)
    article = articles.first

    stub_request(:patch, "http://example.com/articles/1")
      .with(headers: {content_type: "application/vnd.api+json", accept: "application/vnd.api+json"}, body: {
          data: {
            id: "1",
            type: "articles",
            attributes: {
              title: "Modified title",
              foo: "bar"
            }
          }
        }.to_json)
      .to_return(headers: {status: 200, content_type: "application/vnd.api+json"}, body: {
        data: {
          type: "articles",
          id: "1",
          attributes: {
            title: "Modified title",
            foo: "bar"
          }
        }
      }.to_json)

    article.title = "Modified title"
    article.foo = "bar"
    assert article.save
  end

  def test_can_update_found_record_in_bulk
    articles = Article.find(1)
    article = articles.first

    stub_request(:patch, "http://example.com/articles/1")
      .with(headers: {content_type: "application/vnd.api+json", accept: "application/vnd.api+json"}, body: {
          data: {
            id: "1",
            type: "articles",
            attributes: {
              title: "Modified title",
              foo: "bar"
            }
          }
        }.to_json)
      .to_return(headers: {status: 200, content_type: "application/vnd.api+json"}, body: {
        data: {
          id: "1",
          type: "articles",
          attirbutes: {
            title: "Modified title",
            foo: "bar"
          }
        }
      }.to_json)

    assert article.update_attributes({
      title: "Modified title",
      foo: "bar"
    })
  end

  def test_can_update_single_relationship
    articles = Article.find(1)
    article = articles.first

    stub_request(:patch, "http://example.com/articles/1")
      .with(headers: {content_type: "application/vnd.api+json", accept: "application/vnd.api+json"}, body: {
          data: {
            id: "1",
            type: "articles",
            relationships: {
              author: {
                data: {
                  type: "people",
                  id: "1"
                }
              }
            },
            attributes: {}
          }
        }.to_json)
      .to_return(headers: {status: 200, content_type: "application/vnd.api+json"}, body: {
        data: {
          type: "articles",
          id: "1",
          attributes: {
            title: "Rails is Omakase"
          },
          relationships: {
            author: {
              links: {
                self: "/articles/1/links/author",
                related: "/articles/1/author",
              },
              data: { type: "people", id: "1" }
            }
          }
        }
      }.to_json)

    article.relationships.author = Person.new(id: "1")
    assert article.save
  end

  def test_can_update_single_relationship_with_all_attributes_dirty
    articles = Article.find(1)
    article = articles.first

    stub_request(:patch, "http://example.com/articles/1")
        .with(headers: {
                  content_type: "application/vnd.api+json",
                  accept: "application/vnd.api+json"
              }, body: {
                   data: {
                       id: "1",
                       type: "articles",
                       relationships: {
                           author: {
                               data: {
                                   type: "people",
                                   id: "1"
                               }
                           }
                       },
                       attributes: {
                           title: "Rails is Omakase"
                       }
                   }
               }.to_json)
        .to_return(headers: {
                       status: 200,
                       content_type: "application/vnd.api+json"
                   }, body: {
                        data: {
                            type: "articles",
                            id: "1",
                            attributes: {
                                title: "Rails is Omakase"
                            },
                            relationships: {
                                author: {
                                    links: {
                                        self: "/articles/1/links/author",
                                        related: "/articles/1/author",
                                    },
                                    data: {type: "people", id: "1"}
                                }
                            }
                        }
                    }.to_json)

    article.relationships.author = Person.new(id: "1")
    article.set_all_dirty!
    assert article.save
  end

  def test_can_update_has_many_relationships
    articles = Article.find(1)
    article = articles.first

    stub_request(:patch, "http://example.com/articles/1")
      .with(headers: {content_type: "application/vnd.api+json", accept: "application/vnd.api+json"}, body: {
          data: {
            id: "1",
            type: "articles",
            relationships: {
              comments: {
                data: [{
                  type: "comments",
                  id: "2"
                },{
                  type: "comments",
                  id: "3"
                }]
              }
            },
            attributes: {}
          }
        }.to_json)
      .to_return(headers: {status: 200, content_type: "application/vnd.api+json"}, body: {
        data: {
          id: "1",
          type: "articles",
          relationships: {
            author: {
              links: {
                self: "/articles/1/links/author",
                related: "/articles/1/author",
              },
              data: { type: "people", id: "1" }
            }
          },
          attributes: {
            title: "Rails is Omakase"
          }
        }
      }.to_json)

    article.relationships.comments = [
      Comment.new(id: "2"),
      Comment.new(id: "3")
    ]
    assert article.save
  end

  def test_can_update_has_many_relationships_with_all_attributes_dirty
    articles = Article.find(1)
    article = articles.first

    stub_request(:patch, "http://example.com/articles/1")
        .with(headers: {
                  content_type: "application/vnd.api+json",
                  accept: "application/vnd.api+json"
              }, body: {
                   data: {
                       id: "1",
                       type: "articles",
                       relationships: {
                           comments: {
                               data: [{
                                          type: "comments",
                                          id: "2"
                                      }, {
                                          type: "comments",
                                          id: "3"
                                      }]
                           }
                       },
                       attributes: {
                           title: "Rails is Omakase"
                       }
                   }
               }.to_json)
        .to_return(headers: {
                       status: 200,
                       content_type: "application/vnd.api+json"},
                   body: {
                       data: {
                           id: "1",
                           type: "articles",
                           relationships: {
                               author: {
                                   links: {
                                       self: "/articles/1/links/author",
                                       related: "/articles/1/author",
                                   },
                                   data: {type: "people", id: "1"}
                               }
                           },
                           attributes: {
                               title: "Rails is Omakase"
                           }
                       }
                   }.to_json)

    article.relationships.comments = [
        Comment.new(id: "2"),
        Comment.new(id: "3")
    ]
    article.set_all_dirty!
    assert article.save
  end

  def test_callbacks_on_update
    stub_request(:get, "http://example.com/callback_tests/1")
        .to_return(headers: {
                       content_type: "application/vnd.api+json"
                   }, body: {
                        data: {
                            type: "callback_tests",
                            id: "1",
                            attributes: {
                                foo: 1,
                                bar: 1
                            }
                        }
                    }.to_json)

    callback_test = CallbackTest.find(1).first

    stub_request(:patch, "http://example.com/callback_tests/1")
        .with(headers: {
                  content_type: "application/vnd.api+json",
                  accept: "application/vnd.api+json"
              }, body: {
                   data: {
                       id: "1",
                       type: "callback_tests",
                       attributes: {
                           foo: 10
                       }
                   }
               }.to_json)
        .to_return(headers: {
                       status: 200,
                       content_type: "application/vnd.api+json"
                   }, body: {
                        data: {
                            type: "callback_tests",
                            id: "1",
                            attributes: {
                                foo: 10,
                                bar: 1
                            }
                        }
                    }.to_json)

    assert callback_test.save
    assert_equal 100, callback_test.bar
  end

end
