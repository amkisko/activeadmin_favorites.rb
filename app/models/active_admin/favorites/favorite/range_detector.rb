# frozen_string_literal: true

module ActiveAdmin
  module Favorites
    class Favorite
      class RangeDetector
        DATE_PREDICATES = %w[gteq lteq gt lt].freeze
        DATE_PATTERN = /\A\d{4}-\d{2}-\d{2}/

        def self.call(query_string:, resource_key:)
          new(query_string:, resource_key:).call
        end

        def initialize(query_string:, resource_key:)
          @query_filters = QueryParams.parse(query_string).fetch("q", {})
          @resource_key = resource_key
        end

        def call
          attributes = allowed_attributes
          attributes.filter_map do |attribute|
            detect_range(attribute)
          end
        end

        private

        def allowed_attributes
          Favorite.ransackable_attributes_for(@resource_key)
            .select { |attribute| date_like_attribute?(attribute) }
        end

        def date_like_attribute?(attribute)
          DATE_PREDICATES.any? do |predicate|
            value = @query_filters["#{attribute}_#{predicate}"]
            value.present? && value.to_s.match?(DATE_PATTERN)
          end
        end

        def detect_range(attribute)
          gteq = @query_filters["#{attribute}_gteq"].presence
          lteq = @query_filters["#{attribute}_lteq"].presence
          return if gteq.blank? && lteq.blank?

          {
            attribute: attribute,
            gteq: gteq,
            lteq: lteq
          }
        end
      end
    end
  end
end
