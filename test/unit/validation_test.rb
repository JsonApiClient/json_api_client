require 'test_helper'

class ValidationTest < Minitest::Test

  class Office < TestResource
    property :name
    property :email_address

    validates :name, presence: true, on: :create
    validates :email_address, format: /.*@.*/, on: :update
  end

  def test_create_context_validation
    office = Office.new
    office.valid?
    assert office.errors[:name].present?
  end

  def test_create_context_validation_on_update
    office = Office.new
    office.id = "123"
    office.mark_as_persisted!
    office.valid?
    assert office.errors[:name].blank?
  end

  def test_update_context_validation
    office = Office.new(email_address: "123")
    office.id = "123"
    office.mark_as_persisted!
    office.valid?
    assert office.errors[:email_address].present?
  end

  def test_update_context_validation_on_create
    office = Office.new(email_address: "123")
    office.valid?
    assert office.errors[:email_address].blank?
  end
end
