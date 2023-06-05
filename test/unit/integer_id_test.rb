# frozen_string_literal: true

require 'test_helper'

class BaseResource < JsonApiClient::Resource
  self.site = 'http://example.com/'
  def id
    attributes[:id].to_i if attributes[:id].present?
  end
end

class Actor < BaseResource
  has_many :movies
end

class Movie < BaseResource
  belongs_to :actor, shallow_path: true
  has_one :director, shallow_path: true
end

class Director < BaseResource
  has_many :movies
end

NUMERIC_ASSERTION = Gem::Version.new(RUBY_VERSION) < Gem::Version.new('2.4') ? Fixnum : Integer

class IntegerIdTestAssociationTest < MiniTest::Test

  def test_included_document_test_id_from_method_as_integer
    stub_request(:get, 'http://example.com/movies/1?include=actor')
      .to_return(headers: { content_type: 'application/vnd.api+json',
                            accept: 'application/vnd.api+json' },
                 body: {
                   data: {
                     id: '1',
                     type: 'movie',
                     attributes: {
                       actor_id: 1,
                       director_id: 1,
                       created_at: '2021-04-20T17:27:06-07:00',
                       updated_at: '2021-04-20T17:27:07-07:00'
                     },
                     relationships: {
                       actor: {
                         data: {
                           id: '1',
                           type: 'actor'
                         }
                       },
                       director: {
                         data: {
                           id: '1',
                           type: 'director'
                         }
                       }
                     }
                   },
                   included: [
                     {
                       id: '1',
                       type: 'actor',
                       attributes: {
                         name: 'Keanu',
                         updated_at: '2021-04-22T13:50:19-07:00',
                         created_at: '2021-04-19T16:20:13-07:00'
                       }
                     }
                   ]
                 }.to_json)
    movie = Movie.includes(:actor).find(1).last
    assert_equal(NUMERIC_ASSERTION, movie.id.class)
    assert_equal(1, movie.id)
    assert_equal(String, movie.attributes[:id].class)
    assert_equal('1', movie.attributes[:id])
    assert_equal(Actor, movie.actor.class)
    assert_equal(NUMERIC_ASSERTION, movie.actor.id.class)
    assert_equal(1, movie.actor.id)
    assert_equal('1', movie.actor.attributes[:id])
    assert_equal(movie.actor_id, movie.actor.id)
  end

  def test_not_included_data_document
    stub_request(:get, 'http://example.com/movies/1')
      .to_return(headers: { content_type: 'application/vnd.api+json',
                            accept: 'application/vnd.api+json' },
                 body: {
                   data: {
                     id: '1',
                     type: 'movie',
                     attributes: {
                       actor_id: 1,
                       created_at: '2021-04-20T17:27:06-07:00',
                       updated_at: '2021-04-20T17:27:07-07:00'
                     },
                     relationships: {
                       actor: {
                         data: {
                           id: '1',
                           type: 'actor'
                         },
                         director: {
                           data: {
                             id: '1',
                             type: 'director'
                           }
                         }
                       }
                     }
                   }
                 }.to_json)
    movie = Movie.find(1).last
    assert_equal(NUMERIC_ASSERTION, movie.id.class)
    assert_equal(1, movie.id)
    assert_equal(String, movie.attributes[:id].class)
    assert_equal('1', movie.attributes[:id])
    assert_nil(movie.actor)
  end

  def test_not_included_data_document_with_relationships_links
    stub_request(:get, 'http://example.com/movies/1')
      .to_return(headers: { content_type: 'application/vnd.api+json',
                            accept: 'application/vnd.api+json' },
                 body: {
                   data: {
                     id: '1',
                     type: 'movie',
                     attributes: {
                       actor_id: 1,
                       created_at: '2021-04-20T17:27:06-07:00',
                       updated_at: '2021-04-20T17:27:07-07:00'
                     },
                     relationships: {
                       actor: {
                         links: {
                           self: '/movies/1',
                           related: '/actors/1'
                         }
                       },
                       director: {
                         links: {
                           self: '/movies/1',
                           related: '/directors/1'
                         }
                       }
                     }
                   }
                 }.to_json)
    stub_request(:get, 'http://example.com/directors/1')
      .to_return(headers: { content_type: 'application/vnd.api+json',
                            accept: 'application/vnd.api+json' },
                 body: {
                   data: {
                     id: '1',
                     type: 'movie',
                     attributes: {
                       actor_id: 1,
                       created_at: '2021-04-20T17:27:06-07:00',
                       updated_at: '2021-04-20T17:27:07-07:00'
                     },
                     relationships: {
                       actor: {
                         links: {
                           self: '/movies/1',
                           related: '/actors/1'
                         }
                       },
                       director: {
                         links: {
                           self: '/movies/1',
                           related: '/directors/1'
                         }
                       }
                     }
                   }
                 }.to_json)
    movie = Movie.find(1).last
    assert_equal(NUMERIC_ASSERTION, movie.id.class)
    assert_equal(1, movie.id)
    assert_equal(String, movie.attributes[:id].class)
    assert_equal('1', movie.attributes[:id])
    assert_equal(Director, movie.director.class)
  end
end
