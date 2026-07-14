# frozen_string_literal: true

module ActiveAdmin
  module Favorites
    module ViewLens
      class Layout
        VERSION = 1

        def self.normalize(raw_layout)
          layout = raw_layout.is_a?(Hash) ? raw_layout.deep_stringify_keys : {}
          hidden = layout.fetch("hidden", {})
          {
            "version" => layout.fetch("version", VERSION),
            "hidden" => {
              "columns" => Array(hidden["columns"]).map(&:to_s),
              "filters" => Array(hidden["filters"]).map(&:to_s),
              "action_items" => Array(hidden["action_items"]).map(&:to_s),
              "panels" => Array(hidden["panels"]).map(&:to_s),
              "show_rows" => Array(hidden["show_rows"]).map(&:to_s)
            }
          }
        end

        def self.empty
          new({})
        end

        def initialize(raw_layout)
          @layout = self.class.normalize(raw_layout)
        end

        attr_reader :layout

        def hidden_columns
          @layout.dig("hidden", "columns")
        end

        def hidden_filters
          @layout.dig("hidden", "filters")
        end

        def hidden_action_items
          @layout.dig("hidden", "action_items")
        end

        def hidden_panels
          @layout.dig("hidden", "panels")
        end

        def hidden_show_rows
          @layout.dig("hidden", "show_rows")
        end

        def hidden_column?(column_id)
          column_id.present? && hidden_columns.include?(column_id.to_s)
        end

        def hidden_filter?(filter_id)
          filter_id.present? && hidden_filters.include?(filter_id.to_s)
        end

        def hidden_action_item?(action_name)
          action_name.present? && hidden_action_items.include?(action_name.to_s)
        end

        def hidden_panel?(panel_id)
          panel_id.present? && hidden_panels.include?(panel_id.to_s)
        end

        def hidden_show_row?(row_id)
          row_id.present? && hidden_show_rows.include?(row_id.to_s)
        end

        def merge(other)
          return self if other.blank?

          other_layout = self.class.normalize(other.layout || other)
          merged_hidden = layout.fetch("hidden", {}).merge(other_layout.fetch("hidden", {})) do |_key, left, right|
            (left + right).uniq
          end
          self.class.new("version" => VERSION, "hidden" => merged_hidden)
        end
      end
    end
  end
end
