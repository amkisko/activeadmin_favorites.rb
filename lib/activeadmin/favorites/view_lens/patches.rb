# frozen_string_literal: true

module ActiveAdmin
  module Favorites
    module ViewLens
      module TableForPatch
        def column(*args, &block)
          layout = Applicator.current_layout
          resource_key = helpers.active_admin_config&.resource_name&.route_key
          column_id = Applicator.extract_column_id(args, resource_key: resource_key)

          if resource_key.present? && column_id.present?
            label = Applicator.column_label_from_args(args, column_id: column_id)
            Applicator.register_column(resource_key: resource_key, id: column_id, label: label)
          end

          return if layout&.hidden_column?(column_id)

          super
        end
      end

      module AttributesTablePatch
        def row(*args, &block)
          layout = Applicator.current_layout
          title = args[0]
          options = args.last.is_a?(Hash) ? args.last : {}
          row_id = Applicator.extract_row_id(title, options)
          resource_key = helpers.active_admin_config&.resource_name&.route_key

          if resource_key.present? && row_id.present?
            Applicator.register_row(resource_key: resource_key, id: row_id, label: title.to_s)
          end

          return if layout&.hidden_show_row?(row_id)

          super
        end
      end

      module PanelPatch
        def build(title, attributes = {})
          layout = Applicator.current_layout
          panel_id = Applicator.extract_panel_id(title, attributes)
          resource_key = helpers.active_admin_config&.resource_name&.route_key

          if resource_key.present? && panel_id.present?
            Applicator.register_panel(resource_key: resource_key, id: panel_id, label: title.to_s)
          end

          return if layout&.hidden_panel?(panel_id)

          attributes = attributes.merge("data-lens-panel": panel_id)
          super
        end
      end

      module FiltersPatch
        private

        def filter_lookup
          filters = super
          layout = Applicator.current_layout
          return filters if filters.nil?
          return filters unless layout.respond_to?(:hidden_filter?)

          filters.reject { |filter_key, _| layout.hidden_filter?(filter_key) }
        end
      end

      module ActionItemsPatch
        def action_items_for(action, render_context = nil)
          items = super
          layout = Applicator.current_layout
          return items if items.nil?
          return items unless layout.respond_to?(:hidden_action_item?)

          items.reject { |item| layout.hidden_action_item?(item.name) }
        end
      end

      module InstallPatches
        module_function

        def call
          ActiveAdmin::Views::TableFor.prepend(TableForPatch) unless ActiveAdmin::Views::TableFor < TableForPatch
          ActiveAdmin::Views::AttributesTable.prepend(AttributesTablePatch) unless ActiveAdmin::Views::AttributesTable < AttributesTablePatch
          ActiveAdmin::Views::Panel.prepend(PanelPatch) unless ActiveAdmin::Views::Panel < PanelPatch
          ActiveAdmin::Filters::ResourceExtension.prepend(FiltersPatch) unless ActiveAdmin::Filters::ResourceExtension < FiltersPatch
          ActiveAdmin::Resource::ActionItems.prepend(ActionItemsPatch) unless ActiveAdmin::Resource::ActionItems < ActionItemsPatch
        end
      end
    end
  end
end
