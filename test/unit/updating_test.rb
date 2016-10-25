require 'test_helper'

class UpdatingTest < MiniTest::Test

  class Author < TestResource
    def relationships_for_serialization
      super.except('reader')
    end
  end

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

  def test_changed_attributes_blank_after_update
    articles = Article.find(1)
    article = articles.first

    stub_request(:patch, "http://example.com/articles/1")
        .with(headers: {
                  content_type: "application/vnd.api+json",
                  accept: "application/vnd.api+json"
              },
              body: {
                  data: {
                      id: "1",
                      type: "articles",
                      attributes: {
                          title: "Modified title",
                          foo: "bar"
                      }
                  }
              }.to_json)
        .to_return(headers: {
                       status: 200,
                       content_type: "application/vnd.api+json"
                   },
                   body: {
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
    article.save
    assert_empty article.changed_attributes
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

  def test_can_update_found_record_in_builk_using_update_method
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

    assert article.update({
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

  def test_can_not_update_read_only_relationship
    stub_request(:get, "http://example.com/authors/1")
        .to_return(headers: {
                       content_type: "application/vnd.api+json"
                   }, body: {
                        data: {
                            type: "authors",
                            id: "1",
                            attributes: {
                                name: "John Doe"
                            }
                        }
                    }.to_json)

    authors = Author.find(1)
    author = authors.first

    stub_request(:patch, "http://example.com/authors/1")
        .with(headers: {
                  content_type: "application/vnd.api+json",
                  accept: "application/vnd.api+json"
              }, body: {
                   data: {
                       id: "1",
                       type: "authors",
                       attributes: {}
                   }
               }.to_json)
        .to_return(headers: {
                       status: 200,
                       content_type: "application/vnd.api+json"
                   }, body: {
                        data: {
                            type: "authors",
                            id: "1",
                            attributes: {
                                name: "John Doe"
                            }
                        }
                    }.to_json)

    author.relationships.reader = Person.new(id: "1")
    assert author.save
  end

  def test_can_not_update_empty_relationship
    stub_request(:get, "http://example.com/authors/1")
        .to_return(headers: {
                       content_type: "application/vnd.api+json"
                   }, body: {
                        data: {
                            type: "authors",
                            id: "1",
                            attributes: {
                                name: "John Doe"
                            },
                            relationships: {
                                editor: {
                                    links: {
                                        self: "/articles/1/links/editor",
                                        related: "/articles/1/editor"
                                    }
                                }
                            }
                        }
                    }.to_json)

    authors = Author.find(1)
    author = authors.first

    stub_request(:patch, "http://example.com/authors/1")
        .with(headers: {
                  content_type: "application/vnd.api+json",
                  accept: "application/vnd.api+json"
              }, body: {
                   data: {
                       id: "1",
                       type: "authors",
                       attributes: {}
                   }
               }.to_json)
        .to_return(headers: {
                       status: 200,
                       content_type: "application/vnd.api+json"
                   }, body: {
                        data: {
                            type: "authors",
                            id: "1",
                            attributes: {
                                name: "John Doe"
                            },
                            relationships: {
                                editor: {
                                    links: {
                                        self: "/articles/1/links/editor",
                                        related: "/articles/1/editor"
                                    }
                                }
                            }
                        }
                    }.to_json)

    assert author.save
  end

  def test_can_remove_has_one_relationship
    stub_request(:get, "http://example.com/authors/1")
        .to_return(headers: {
                       content_type: "application/vnd.api+json"
                   }, body: {
                        data: {
                            type: "authors",
                            id: "1",
                            attributes: {
                                name: "John Doe"
                            },
                            relationships: {
                                editor: {
                                    links: {
                                        self: "/articles/1/links/editor",
                                        related: "/articles/1/editor"
                                    },
                                    data: {id: '2', type: 'editors'}
                                }
                            }
                        }
                    }.to_json)

    authors = Author.find(1)
    author = authors.first

    stub_request(:patch, "http://example.com/authors/1")
        .with(headers: {
                  content_type: "application/vnd.api+json",
                  accept: "application/vnd.api+json"
              }, body: {
                   data: {
                       id: "1",
                       type: "authors",
                       relationships: {
                           editor: {
                               data: nil
                           }
                       },
                       attributes: {}
                   }
               }.to_json)
        .to_return(headers: {
                       status: 200,
                       content_type: "application/vnd.api+json"
                   }, body: {
                        data: {
                            type: "authors",
                            id: "1",
                            relationships: {
                                editor: {
                                    links: {
                                        self: "/articles/1/links/editor",
                                        related: "/articles/1/editor"
                                    }
                                }
                            },
                            attributes: {
                                name: "John Doe"
                            }
                        }
                    }.to_json)

    author.relationships.editor = nil
    assert author.save
  end

  def test_can_remove_has_many_relationship
    stub_request(:get, "http://example.com/authors/1")
        .to_return(headers: {
                       content_type: "application/vnd.api+json"
                   }, body: {
                        data: {
                            type: "authors",
                            id: "1",
                            attributes: {
                                name: "John Doe"
                            },
                            relationships: {
                                articles: {
                                    links: {
                                        self: "/articles/1/links/articles",
                                        related: "/articles/1/articles"
                                    },
                                    data: [
                                        {id: '2', type: 'articles'},
                                        {id: '3', type: 'articles'}
                                    ]
                                }
                            }
                        }
                    }.to_json)

    authors = Author.find(1)
    author = authors.first

    stub_request(:patch, "http://example.com/authors/1")
        .with(headers: {
                  content_type: "application/vnd.api+json",
                  accept: "application/vnd.api+json"
              }, body: {
                   data: {
                       id: "1",
                       type: "authors",
                       relationships: {
                           articles: {
                               data: []
                           }
                       },
                       attributes: {}
                   }
               }.to_json)
        .to_return(headers: {
                       status: 200,
                       content_type: "application/vnd.api+json"
                   }, body: {
                        data: {
                            type: "authors",
                            id: "1",
                            relationships: {
                                articles: {
                                    links: {
                                        self: "/articles/1/links/articles",
                                        related: "/articles/1/articles"
                                    }
                                }
                            },
                            attributes: {
                                name: "John Doe"
                            }
                        }
                    }.to_json)

    author.relationships.articles = []
    assert author.save
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
