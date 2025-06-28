# frozen_string_literal: true

require "active_model"
require "active_support/i18n"
I18n.load_path += Dir["#{File.dirname(__FILE__)}/locale/*.yml"]

module ActiveModel
  module Validations
    class SiretValidator < ActiveModel::EachValidator
      LA_POSTE_SIREN = "356000000"
      LA_POSTE_SIRET_SIEGE = "35600000000048"

      def validate_each(record, attribute, value)
        if !valid_format?(value)
          record.errors.add(attribute, :wrong_siret_format, **options)
        elsif !valid_checksum?(value)
          record.errors.add(attribute, :invalid, **options)
        end
      end

      private

      def valid_format?(value)
        value&.match?(/^\d{14}$/)
      end

      def valid_checksum?(value)
        if siret_attached_to_la_poste?(value)
          valid_la_poste_checksum?(value)
        else
          valid_luhn?(value)
        end
      end

      def siret_attached_to_la_poste?(value)
        value[0..8] == LA_POSTE_SIREN
      end

      def valid_luhn?(value)
        (luhn_checksum(value) % 10 == 0)
      end

      def luhn_checksum(value)
        value.reverse.each_char.map(&:to_i).map.with_index do |digit, index|
          t = index.even? ? digit : digit * 2
          t < 10 ? t : t - 9
        end.sum
      end

      def valid_la_poste_checksum?(value)
        value == LA_POSTE_SIRET_SIEGE || (la_poste_checksum(value) % 5 == 0)
      end

      def la_poste_checksum(value)
        value.each_char.map(&:to_i).sum
      end
    end

    module HelperMethods
      # Validates whether the value of the specified attribute is a valid SIRET number.
      #
      # A SIRET number is valid if:
      # * It is made of exactly 14 digits (otherwise a `:wrong_siret_format` error is added).
      # * Its checksum is valid (otherwise an `:invalid` error is added).
      #
      #   class TaxesFilling
      #     include ActiveModel::Validations
      #     attr_accessor :company_siret
      #     validates_siret_of :company_siret
      #   end
      #
      # Configuration options:
      # * <tt>:message</tt> - A custom error message.
      #
      # There is also a list of default options supported by every validator:
      # +:if+, +:unless+, +:on+, +:allow_nil+, +:allow_blank+, and +:strict+.
      # See ActiveModel::Validations::ClassMethods#validates for more information.
      def validates_siret_of(*attr_names)
        validates_with SiretValidator, _merge_attributes(attr_names)
      end
    end
  end
end
