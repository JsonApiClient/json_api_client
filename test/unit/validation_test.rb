require 'test_helper'

class ValidationTest < Minitest::Test

  class Office < TestResource
    property :name
    property :email_address

    validates :name, presence: true
    validates :email_address, format: /.*@.*/
  end

  def test_can_add_client_side_validations

    office = Office.new
    assert_equal false, office.save

    assert office.errors[:name].present?
    assert office.errors[:email_address].present?

  end

end