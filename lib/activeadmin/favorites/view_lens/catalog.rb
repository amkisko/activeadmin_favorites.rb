# frozen_string_literal: true

module ActiveAdmin
  module Favorites
    module ViewLens
      class Catalog
        Entry = Data.define(:id, :label, :group)

        def self.for(active_admin_config:, action:, render_context: nil)
          new(active_admin_config:, action:, render_context:).call
        end

        def initialize(active_admin_config:, action:, render_context: nil)
          @active_admin_config = active_admin_config
          @action = action.to_s
          @render_context = render_context
        end

        def call
          case @action
          when "index"
            index_entries
          when "show"
            show_entries
          else
            []
          end
        end

        private

        def index_entries
          entries = []
          entries.concat(column_entries)
          entries.concat(filter_entries)
          entries.concat(action_item_entries(:index))
          entries
        end

        def show_entries
          entries = []
          entries.concat(panel_entries)
          entries.concat(row_entries)
          entries.concat(action_item_entries(:show))
          entries
        end

        def column_entries
          registered = ViewLens::Applicator.registered_columns[@active_admin_config.resource_name.route_key] || []
          registered.map do |column|
            Entry.new(
              id: column[:id],
              label: column[:label],
              group: "columns"
            )
          end
        end

        def filter_entries
          return [] unless @active_admin_config.filters_enabled?

          filters = @active_admin_config.filters
          return [] if filters.blank?

          filters.keys.map do |filter_key|
            filter = @active_admin_config.filters[filter_key]
            label = filter[:label] || filter_key.to_s.titleize
            Entry.new(id: filter_key.to_s, label: label.to_s, group: "filters")
          end
        end

        def action_item_entries(action)
          action_items = @active_admin_config.action_items
          return [] if action_items.blank?

          action_items
            .select { |item| item.display_on?(action, @render_context) }
            .reject { |item| item.name.to_s.start_with?("personalize_page") }
            .map do |item|
              Entry.new(
                id: item.name.to_s,
                label: I18n.t("active_admin.favorites.action_items.#{item.name}", default: item.name.to_s.humanize),
                group: "action_items"
              )
            end
        end

        def panel_entries
          registered = ViewLens::Applicator.registered_panels[@active_admin_config.resource_name.route_key] || []
          registered.map do |panel|
            Entry.new(id: panel[:id], label: panel[:label], group: "panels")
          end
        end

        def row_entries
          registered = ViewLens::Applicator.registered_rows[@active_admin_config.resource_name.route_key] || []
          registered.map do |row|
            Entry.new(id: row[:id], label: row[:label], group: "show_rows")
          end
        end

        def self.grouped(entries)
          entries.group_by(&:group)
        end
      end
    end
  end
end
