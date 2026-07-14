# frozen_string_literal: true

module ActiveAdmin
  module Favorites
    class Favorite
      class MacroValidator
        class ValidationError < StandardError; end

        def self.validate!(macros, resource_key:)
          new(macros, resource_key:).validate!
        end

        def initialize(macros, resource_key:)
          @macros = Array(macros)
          @resource_key = resource_key
          @allowed_attributes = Favorite.ransackable_attributes_for(resource_key)
        end

        def validate!
          raise ValidationError, "macros must be an array" unless @macros.is_a?(Array)
          raise ValidationError, "too many macros" if @macros.size > MacroResolver::MAX_MACROS

          @macros.each { |macro| validate_macro!(macro) }
          true
        end

        private

        def validate_macro!(macro)
          raise ValidationError, "macro must be an object" unless macro.is_a?(Hash)
          raise ValidationError, "macro type is required" if macro["type"].blank?

          case macro["type"]
          when "template"
            validate_template!(macro)
          when "relative_time_range"
            validate_relative_time_range!(macro)
          when "relative_time_bound"
            validate_relative_time_bound!(macro)
          else
            raise ValidationError, "unsupported macro type: #{macro["type"]}"
          end
        end

        def validate_template!(macro)
          MacroCatalog.fetch(macro.fetch("name"))
          validate_attribute!(macro.fetch("attribute"))
        end

        def validate_relative_time_range!(macro)
          MacroCatalog.fetch(macro.fetch("preset"))
          validate_attribute!(macro.fetch("attribute"))
        end

        def validate_relative_time_bound!(macro)
          validate_attribute!(macro.fetch("attribute"))
          predicate = macro.fetch("predicate")
          unit = macro.fetch("unit")
          anchor = macro.fetch("anchor")
          offset = macro.fetch("offset").to_i

          unless MacroResolver::ALLOWED_PREDICATES.include?(predicate)
            raise ValidationError, "invalid predicate: #{predicate}"
          end
          unless MacroResolver::ALLOWED_UNITS.include?(unit)
            raise ValidationError, "invalid unit: #{unit}"
          end
          unless MacroResolver::ALLOWED_ANCHORS.include?(anchor)
            raise ValidationError, "invalid anchor: #{anchor}"
          end
          if offset.abs > 120
            raise ValidationError, "offset out of range"
          end
        end

        def validate_attribute!(attribute)
          unless attribute.to_s.match?(/\A[a-z0-9_]+\z/)
            raise ValidationError, "invalid attribute name"
          end
          unless @allowed_attributes.include?(attribute.to_s)
            raise ValidationError, "attribute not allowed for resource: #{attribute}"
          end
        end
      end
    end
  end
end
