require 'test_helper'

class Author < TestResource
end

class EditingTest < MiniTest::Test

  def test_attribute_changed
    stub_request(:get, "http://example.com/authors/1")
        .to_return(headers: {content_type: "application/vnd.api+json"},
                   body: {
                       data: {
                           type: "authors",
                           id: "1",
                           attributes: {
                               name: "John Doe",
                               nickname: "jdoe"
                           }
                       }
                   }.to_json)

    authors = Author.find(1)
    author = authors.first
    author.name = "Bob Marley"

    assert_equal(true, author.attribute_changed?('name'))
    assert_equal(true, author.attribute_changed?(:name))
    assert_equal(true, author.name_changed?)
    assert_equal(false, author.attribute_changed?('nickname'))
    assert_equal(false, author.attribute_changed?(:nickname))
    assert_equal(false, author.nickname_changed?)
  end

  def test_attribute_was
    stub_request(:get, "http://example.com/authors/1")
        .to_return(headers: {content_type: "application/vnd.api+json"},
                   body: {
                       data: {
                           type: "authors",
                           id: "1",
                           attributes: {
                               name: "John Doe",
                               nickname: "jdoe"
                           }
                       }
                   }.to_json)

    authors = Author.find(1)
    author = authors.first
    old_name = author.name
    author.name = "Bob Marley"

    assert_equal(old_name, author.attribute_was('name'))
    assert_equal(old_name, author.attribute_was(:name))
    assert_equal(old_name, author.name_was)
    assert_equal(author.nickname, author.attribute_was('nickname'))
    assert_equal(author.nickname, author.attribute_was(:nickname))
    assert_equal(author.nickname, author.nickname_was)
  end

end
