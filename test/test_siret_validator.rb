# frozen_string_literal: true

require "test_helper"

class TestSiretValidator < Minitest::Spec
  VALID_SIRET = "82161143100031"
  INVALID_SIRET = "82161143100039"

  class Company
    include ActiveModel::Model
    attr_accessor :siret
  end

  def teardown
    Company.clear_validators!
  end

  def test_validate_siret
    Company.validates_siret_of(:siret)

    model = Company.new(siret: INVALID_SIRET)
    assert_predicate model, :invalid?
    assert model.errors.has_key?(:siret)

    model.siret = VALID_SIRET
    assert_predicate model, :valid?
    refute model.errors.has_key?(:siret)
  end

  def test_validate_siret_cases
    Company.validates_siret_of(:siret)

    cases = {
      nil               => :wrong_siret_format, # nil
      ""                => :wrong_siret_format, # blank
      "8216114310003"   => :wrong_siret_format, # too short
      "invalid--siret"  => :wrong_siret_format, # invalid characters
      "82161143100031"  => nil,                 # valid siret
      "821611431000314" => :wrong_siret_format, # too long
      "82161143100039"  => :invalid,            # invalid luhn
      "35600000000048"  => nil,                 # La Poste siège
      "35600000041461"  => nil,                 # La Poste établissement
      "35600000041462"  => :invalid             # invalid La Poste établissement
    }

    cases.each do |(siret, expected_error)|
      assert_siret_validity(siret, expected_error)
    end
  end

  def test_validate_siret_with_allow_nil
    Company.validates_siret_of(:siret, allow_nil: true)

    assert_predicate Company.new(siret: nil), :valid?
    assert_predicate Company.new(siret: ""),  :invalid?
    assert_predicate Company.new(siret: "1"), :invalid?
  end

  def test_validate_siret_with_allow_blank
    Company.validates_siret_of(:siret, allow_blank: true)

    assert_predicate Company.new(siret: nil), :valid?
    assert_predicate Company.new(siret: ""),  :valid?
    assert_predicate Company.new(siret: "1"), :invalid?
  end

  def test_validate_siret_localized_message
    Company.validates_siret_of(:siret)

    c = Company.new(siret: "foo")

    with_locale(:en) do
      assert_equal c.tap(&:validate).errors[:siret], ["must be a number of exactly 14 digits"]
    end

    with_locale(:fr) do
      assert_equal c.tap(&:validate).errors[:siret], ["doit être un numéro d’exactement 14 chiffres"]
    end
  end

  def test_validate_siret_with_custom_message
    Company.validates_siret_of(:siret, message: "is invalid")

    c = Company.new(siret: "foo").tap(&:validate)
    assert_equal c.errors[:siret], ["is invalid"]
  end

  private

  def assert_siret_validity(siret, expected_error)
    model = Company.new(siret: siret).tap(&:validate)
    if expected_error.present?
      assert(model.errors.where(:siret, expected_error).present?, "Expected '#{siret}' to generate a ':#{expected_error}' validation error")
    else
      assert_empty(model.errors[:siret], "Expected '#{siret}' to be valid")
    end
  end

  def with_locale(locale, &)
    original_locale = I18n.locale
    I18n.locale = locale
    begin
      yield
    ensure
      I18n.locale = original_locale
    end
  end
end
