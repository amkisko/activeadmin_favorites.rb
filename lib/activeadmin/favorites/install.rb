# frozen_string_literal: true

module ActiveAdmin
  module Favorites
    module Install
      FILTER_FAVOURITE_ACTION = :save_filter_favorite
      PERSONALIZE_ACTION = :personalize_page

      module_function

      def call
        install_controller_methods!
        install_action_items!
        configure_favorites_resource!
        ViewLens::InstallPatches.call
      end

      def configure_favorites_resource!
        resource = ActiveAdmin.application.namespace(ActiveAdmin::Favorites.config.namespace_name)
          .resources.find { |config| config.resource_class == Favorite }
        return unless resource

        resource.instance_variable_set(:@batch_actions, {}) if resource.instance_variable_get(:@batch_actions).nil?

        if resource.respond_to?(:batch_actions=)
          resource.batch_actions = false
        else
          resource.instance_variable_set(:@batch_actions_enabled, false)
        end
      end

      def install_controller_methods!
        return unless defined?(ActiveAdmin::ResourceController)

        controller = ActiveAdmin::ResourceController
        return if controller.included_modules.include?(ViewLens::ControllerMethods)

        controller.include(ViewLens::ControllerMethods)
      end

      def install_action_items!
        ActiveAdmin.application.namespaces.each do |namespace|
          namespace.resources.each do |config|
            next if config.is_a?(ActiveAdmin::Page)
            next unless config.controller.action_methods.include?("index")
            next if config.resource_class == Favorite

            install_filter_favorite_action_item!(config)
            install_personalize_action_item!(config)
            install_show_personalize_action_item!(config)
          end
        end
      end

      def install_filter_favorite_action_item!(config)
        return if config.action_items.any? { |item| item.name == FILTER_FAVOURITE_ACTION }

        config.add_action_item(FILTER_FAVOURITE_ACTION, only: :index, priority: 5) do
          sanitized_query = Favorite.sanitize_query_string(request.query_string)
          user = send(ActiveAdmin::Favorites.config.current_user_method)

          if sanitized_query.blank?
            label = I18n.t("active_admin.favorites.add_favorite")
            destination = new_admin_favorite_path(
              path: request.path,
              query_string: sanitized_query,
              resource_key: active_admin_config.resource_name.route_key,
              action_name: "index"
            )
          else
            lookup = {
              path: request.path,
              query_string: sanitized_query
            }
            lookup[ActiveAdmin::Favorites.config.user_foreign_key] = user.id
            owned_existing = Favorite.filters_kind.find_by(lookup)

            label = if owned_existing
              I18n.t("active_admin.favorites.edit_favorite")
            else
              I18n.t("active_admin.favorites.add_favorite")
            end

            destination = if owned_existing
              edit_admin_favorite_path(owned_existing)
            else
              new_admin_favorite_path(
                path: request.path,
                query_string: sanitized_query,
                resource_key: active_admin_config.resource_name.route_key,
                action_name: "index"
              )
            end
          end

          link_to label, destination, class: "action-item-button"
        end
      end

      def install_personalize_action_item!(config)
        return unless config.controller.action_methods.include?("index")
        return if config.action_items.any? { |item| item.name == :"#{PERSONALIZE_ACTION}_index" }

        config.add_action_item(:"#{PERSONALIZE_ACTION}_index", only: :index, priority: 1) do
          render partial: "active_admin/favorites/personalization_trigger",
            locals: {action_name: "index"}
        end
      end

      def install_show_personalize_action_item!(config)
        return unless config.controller.action_methods.include?("show")
        return if config.action_items.any? { |item| item.name == :"#{PERSONALIZE_ACTION}_show" }

        config.add_action_item(:"#{PERSONALIZE_ACTION}_show", only: :show, priority: 1) do
          render partial: "active_admin/favorites/personalization_trigger",
            locals: {action_name: "show"}
        end
      end
    end
  end
end
