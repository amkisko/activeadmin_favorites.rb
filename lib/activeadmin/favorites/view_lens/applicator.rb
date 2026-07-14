# frozen_string_literal: true

module ActiveAdmin
  module Favorites
    module ViewLens
      class Applicator
        class << self
          def current_layout
            value = Current.layout
            return Layout.empty if value.nil?
            return value if value.is_a?(Layout)

            Layout.new(value)
          end

          def current_layout=(value)
            Current.layout = value
          end

          def current_catalog
            Current.catalog
          end

          def current_catalog=(value)
            Current.catalog = value
          end

          def registered_columns
            Current.registered_columns
          end

          def registered_panels
            Current.registered_panels
          end

          def registered_rows
            Current.registered_rows
          end

          def reset!
            Current.reset
          end

          def resolve_layout(controller:)
            user = controller.send(ActiveAdmin::Favorites.config.current_user_method)
            config = controller.send(:active_admin_config)
            action = controller.action_name
            resource_key = config.resource_name.route_key

            layout = ViewLens::Layout.empty
            default = ViewLensDefault.for_user(user, resource_key: resource_key, action: action)
            layout = layout.merge(default.layout_object) if default

            favorite_id = controller.params[:favorite_id]
            if favorite_id.present?
              bookmark = Favorite.visible_to(user).find_by(id: favorite_id)
              if bookmark&.layout.present? && bookmark.resource_key == resource_key && bookmark.action == action
                layout = layout.merge(bookmark.layout_object)
              end
            end

            Current.layout = layout
            Current.catalog_context = {
              active_admin_config: config,
              action: action,
              render_context: controller.helpers
            }
            layout
          end

          def build_catalog(active_admin_config:, action:, render_context: nil)
            Catalog.for(
              active_admin_config: active_admin_config,
              action: action,
              render_context: render_context
            )
          end

          def catalog_payload(active_admin_config:, action:, render_context: nil)
            build_catalog(
              active_admin_config: active_admin_config,
              action: action,
              render_context: render_context
            ).map do |entry|
              {id: entry.id, label: entry.label, group: entry.group}
            end
          end

          def register_column(resource_key:, id:, label:)
            return if id.blank?

            registered_columns[resource_key] << {id: id.to_s, label: label.to_s}
          end

          def register_panel(resource_key:, id:, label:)
            return if id.blank?

            registered_panels[resource_key] << {id: id.to_s, label: label.to_s}
          end

          def register_row(resource_key:, id:, label:)
            return if id.blank?

            registered_rows[resource_key] << {id: id.to_s, label: label.to_s}
          end

          def extract_column_id(args, resource_key: nil)
            title = args[0]
            return title.to_s if title.is_a?(Symbol)
            return title.to_s.parameterize(separator: "_") if title.is_a?(String) && title.present?

            options = args.last.is_a?(Hash) ? args.last : {}
            return options[:lens_id].to_s if options[:lens_id].present?

            next_block_column_id(resource_key) if resource_key.present?
          end

          def column_label_from_args(args, column_id:)
            title = args[0]
            options = args.last.is_a?(Hash) ? args.last : {}
            return options[:label].to_s if options[:label].present?
            return title.to_s.humanize if title.is_a?(Symbol)
            return title if title.is_a?(String) && title.present?

            if column_id.to_s.start_with?("block_column_")
              position = column_id.to_s.delete_prefix("block_column_")
              return I18n.t("active_admin.favorites.block_column", position: position, default: "Custom column %{position}")
            end

            column_id.to_s.humanize
          end

          def next_block_column_id(resource_key)
            sequence = Current.block_column_sequence
            sequence[resource_key] += 1
            "block_column_#{sequence[resource_key]}"
          end

          def extract_panel_id(title, options)
            options[:lens_id]&.to_s.presence || title.to_s.parameterize(separator: "_")
          end

          def extract_row_id(title, options)
            options[:lens_id]&.to_s.presence || title.to_s.parameterize(separator: "_")
          end
        end
      end
    end
  end
end
