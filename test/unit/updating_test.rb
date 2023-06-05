require 'test_helper'

class UpdatingTest < MiniTest::Test

  class Author < TestResource
    def relationships_for_serialization
      super.except('reader')
    end
  end

  class Editor < TestResource
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

  def stub_simple_fetch
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

  def test_failed_update!
    stub_simple_fetch
    articles = Article.find(1)
    article = articles.first

    stub_request(:patch, "http://example.com/articles/1")
      .with(headers: {content_type: "application/vnd.api+json", accept: "application/vnd.api+json"}, body: {
          data: {
            id: "1",
            type: "articles",
            attributes: {
              title: "Modified title",
            }
          }
        }.to_json)
      .to_return(headers: {content_type: "application/vnd.api+json"}, body: {
        errors: [
          {
            status: "400",
            title: "Error"
          }
        ]
      }.to_json)

    exception = assert_raises JsonApiClient::Errors::RecordNotSaved do
      article.update!(title: 'Modified title')
    end
    assert_equal "Record not saved", exception.message
  end

  def test_can_update_found_record
    stub_simple_fetch
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
    stub_simple_fetch
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
    stub_simple_fetch
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
    stub_simple_fetch
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
    stub_simple_fetch
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

  def test_can_update_single_relationship_via_setter
    stub_simple_fetch
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

    article.author = Person.new(id: "1")
    assert article.save
  end

  def test_can_update_single_relationship_with_all_attributes_dirty
    stub_simple_fetch
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
    stub_simple_fetch
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

  def test_can_update_has_many_relationships_via_setter
    stub_simple_fetch
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

    article.comments = [
        Comment.new(id: "2"),
        Comment.new(id: "3")
    ]
    assert article.save
  end

  def test_can_update_has_many_relationships_with_all_attributes_dirty
    stub_simple_fetch
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

  def test_can_update_with_includes_and_fields
    stub_simple_fetch
    stub_request(:patch, "http://example.com/articles/1")
        .with(
            headers: {content_type: "application/vnd.api+json", accept: "application/vnd.api+json"},
            query: {include: 'comments,author.comments', fields: {articles: 'title', authors: 'name'}},
            body: {
                data: {
                    id: "1",
                    type: "articles",
                    attributes: {
                        title: "Modified title"
                    }
                }
            }.to_json
        ).to_return(headers: {content_type: "application/vnd.api+json"}, body: {
        data: {
            type: "articles",
            id: "1",
            attributes: {
                title: "Modified title"
            },
            relationships: {
                comments: {
                    data: [
                        {
                            id: "2",
                            type: "comments"
                        }
                    ]
                },
                author: {
                    data: nil
                }
            }
        },
        included: [
            {
                id: "2",
                type: "comments",
                attributes: {
                    body: "it is isn't it ?"
                }
            }
        ]
    }.to_json)
    stub_request(:patch, "http://example.com/articles/1")
        .with(
            headers: {content_type: "application/vnd.api+json", accept: "application/vnd.api+json"},
            body: {
                data: {
                    id: "1",
                    type: "articles",
                    attributes: {
                        title: "Modified title 2"
                    }
                }
            }.to_json
        ).to_return(
            headers: {content_type: "application/vnd.api+json"},
            body: {
                data: {
                    type: "articles",
                    id: "1",
                    attributes: {
                        title: "Modified title 2"
                    }
                }
            }.to_json
    )
    article = Article.find(1).first
    article.title = "Modified title"
    article.request_includes(:comments, author: :comments).
        request_select(articles: [:title], authors: [:name])

    assert article.save
    assert_equal "1", article.id
    assert_equal "Modified title", article.title
    assert_nil article.author
    assert_equal 1, article.comments.size
    assert_equal "2", article.comments.first.id
    assert_equal "it is isn't it ?", article.comments.first.body

    article.title = "Modified title 2"
    assert article.save
    assert_equal "Modified title 2", article.title
  end

  def test_can_update_with_includes_and_fields_with_keep_request_params
    stub_simple_fetch
    stub_request(:patch, "http://example.com/articles/1")
        .with(
            headers: {content_type: "application/vnd.api+json", accept: "application/vnd.api+json"},
            query: {include: 'comments,author.comments', fields: {articles: 'title', authors: 'name'}},
            body: {
                data: {
                    id: "1",
                    type: "articles",
                    attributes: {
                        title: "Modified title"
                    }
                }
            }.to_json
        ).to_return(headers: {content_type: "application/vnd.api+json"}, body: {
        data: {
            type: "articles",
            id: "1",
            attributes: {
                title: "Modified title"
            },
            relationships: {
                comments: {
                    data: [
                        {
                            id: "2",
                            type: "comments"
                        }
                    ]
                },
                author: {
                    data: nil
                }
            }
        },
        included: [
            {
                id: "2",
                type: "comments",
                attributes: {
                    body: "it is isn't it ?"
                }
            }
        ]
    }.to_json)
    stub_request(:patch, "http://example.com/articles/1")
        .with(
            headers: {content_type: "application/vnd.api+json", accept: "application/vnd.api+json"},
            query: {include: 'comments,author.comments', fields: {articles: 'title', authors: 'name'}},
            body: {
                data: {
                    id: "1",
                    type: "articles",
                    attributes: {
                        title: "Modified title 2"
                    }
                }
            }.to_json
        ).to_return(
        headers: {content_type: "application/vnd.api+json"},
        body: {
            data: {
                type: "articles",
                id: "1",
                attributes: {
                    title: "Modified title 2"
                },
                relationships: {
                    comments: {
                        data: [
                            {
                                id: "2",
                                type: "comments"
                            }
                        ]
                    },
                    author: {
                        data: nil
                    }
                }
            },
            included: [
                {
                    id: "2",
                    type: "comments",
                    attributes: {
                        body: "it is isn't it ?"
                    }
                }
            ]
        }.to_json
    )
    Article.keep_request_params = true
    article = Article.find(1).first
    article.title = "Modified title"
    article.request_includes(:comments, author: :comments).
        request_select(:title, authors: [:name])

    assert article.save
    assert_equal "1", article.id
    assert_equal "Modified title", article.title
    assert_nil article.author
    assert_equal 1, article.comments.size
    assert_equal "2", article.comments.first.id
    assert_equal "it is isn't it ?", article.comments.first.body

    article.title = "Modified title 2"
    assert article.save
    assert_equal "Modified title 2", article.title
    assert_nil article.author
    assert_equal 1, article.comments.size
    assert_equal "2", article.comments.first.id
    assert_equal "it is isn't it ?", article.comments.first.body
  ensure
    Article.keep_request_params = false
  end

  def test_fetch_with_relationships_and_update_attribute
    stub_request(:get, "http://example.com/authors/1?include=editor")
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
                        data: {id: "2", type: "editors"}
                    }
                }
            }
        }.to_json)

    authors = Author.includes(:editor).find(1)
    author = authors.first

    stub_request(:patch, "http://example.com/authors/1")
        .with(headers: {
            content_type: "application/vnd.api+json",
            accept: "application/vnd.api+json"
        }, body: {
            data: {
                id: "1",
                type: "authors",
                attributes: {
                    name: "Jane Doe"
                }
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
                    name: "Jane Doe"
                }
            }
        }.to_json)

    author.name = "Jane Doe"
    assert author.save
  end

  def test_fetch_with_relationships_and_update_relationships
    stub_request(:get, "http://example.com/authors/1?include=editor")
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
                        data: {id: "2", type: "editors"}
                    }
                }
            }
        }.to_json)

    authors = Author.includes(:editor).find(1)
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
                        data: {type: "editors", id: "3"}
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

    author.relationships.editor = Editor.new(id: '3')
    assert author.save
  end

end
