# frozen_string_literal: true

module ActiveAdmin
  module Favorites
    class Favorite
      class MacroBuilder
        def self.from_template_assignments(assignments)
          assignment_rows(assignments).filter_map do |assignment|
            next unless ActiveModel::Type::Boolean.new.cast(assignment["enabled"])

            attribute = assignment["attribute"].to_s
            template_name = assignment["name"].to_s
            next if attribute.blank? || template_name.blank?

            {
              "type" => "template",
              "name" => template_name,
              "attribute" => attribute
            }
          end
        end

        def self.from_json(json_string)
          parsed = JSON.parse(json_string)
          raise JSON::ParserError unless parsed.is_a?(Array)

          parsed
        end

        def self.template(attribute, name:)
          [{"type" => "template", "name" => name.to_s, "attribute" => attribute.to_s}]
        end

        def self.assignment_rows(assignments)
          return [] if assignments.blank?

          HashCoercion.assignment_values(assignments)
        end
        private_class_method :assignment_rows
      end
    end
  end
end
