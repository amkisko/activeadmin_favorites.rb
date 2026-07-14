# frozen_string_literal: true

module ActiveAdmin
  module Favorites
    class Favorite
      class MacroResolver
        ALLOWED_UNITS = %w[day week month year].freeze
        ALLOWED_ANCHORS = %w[beginning_of_unit end_of_unit].freeze
        ALLOWED_PREDICATES = %w[gteq lteq].freeze
        MAX_MACROS = 10

        def self.call(macros:, at: Time.zone.now)
          new(macros:, at:).call
        end

        def self.q_keys(macros)
          call(macros: macros, at: Time.zone.now).keys
        end

        def initialize(macros:, at:)
          @macros = Array(macros)
          @at = at.in_time_zone
        end

        def call
          @macros.each_with_object({}) do |macro, resolved|
            raise ArgumentError, "too many macros" if resolved.size > MAX_MACROS

            resolved.merge!(resolve_macro(macro))
          end
        end

        private

        def resolve_macro(macro)
          case macro["type"]
          when "template"
            resolve_template(macro)
          when "relative_time_range"
            resolve_relative_time_range(macro)
          when "relative_time_bound"
            key, value = resolve_relative_time_bound(macro)
            {key => value}
          else
            raise ArgumentError, "unsupported macro type: #{macro["type"]}"
          end
        end

        def resolve_template(macro)
          MacroCatalog.resolve(macro.fetch("name"), attribute: macro.fetch("attribute"), at: @at)
        end

        def resolve_relative_time_range(macro)
          MacroCatalog.resolve(macro.fetch("preset"), attribute: macro.fetch("attribute"), at: @at)
        end

        def resolve_relative_time_bound(macro)
          attribute = macro.fetch("attribute")
          predicate = macro.fetch("predicate")
          unit = macro.fetch("unit")
          offset = macro.fetch("offset").to_i
          anchor = macro.fetch("anchor")

          unless ALLOWED_UNITS.include?(unit) && ALLOWED_ANCHORS.include?(anchor) && ALLOWED_PREDICATES.include?(predicate)
            raise ArgumentError, "invalid relative_time_bound macro"
          end

          if offset.abs > 120
            raise ArgumentError, "offset out of range"
          end

          date = @at.to_date
          shifted = date.advance("#{unit}s": offset)
          bound =
            if anchor == "beginning_of_unit"
              shifted.public_send("beginning_of_#{unit}")
            else
              shifted.public_send("end_of_#{unit}")
            end

          ["#{attribute}_#{predicate}", MacroCatalog.format_date(bound)]
        end
      end
    end
  end
end
