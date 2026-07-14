# frozen_string_literal: true

module ActiveAdmin
  module Favorites
    module RegisterViewLensPreferences
      PAGE_NAME = "ViewLensPreferences"

      module_function

      def parse_layout_param(raw_layout)
        parsed =
          if raw_layout.is_a?(String)
            JSON.parse(raw_layout)
          elsif raw_layout.respond_to?(:to_unsafe_h)
            raw_layout.to_unsafe_h
          else
            raw_layout
          end
        ViewLens::Layout.normalize(parsed || {})
      rescue JSON::ParserError
        ViewLens::Layout.empty.layout
      end

      def call
        return if page_registered?

        ActiveAdmin.register_page PAGE_NAME, as: "view_lens_preferences" do
          menu false

          controller do
            def layout_from_request
              ActiveAdmin::Favorites::RegisterViewLensPreferences.parse_layout_param(params[:layout])
            end

            def authorize_view_lens_page_action!(action_name)
              return unless respond_to?(:authorized?, true)

              return if authorized?(action_name, active_admin_config)

              redirect_to admin_root_path,
                alert: I18n.t("active_admin.access_denied.message", default: "You are not authorized to perform this action.")
            end
          end

          page_action :update, method: :patch do
            authorize_view_lens_page_action!(:update)
            user = send(ActiveAdmin::Favorites.config.current_user_method)
            layout = ActiveAdmin::Favorites::RegisterViewLensPreferences.parse_layout_param(params[:layout])
            ViewLensDefault.upsert_for!(
              user: user,
              resource_key: params.fetch(:resource_key),
              action: params.fetch(:view_lens_action),
              layout: layout
            )
            redirect_back fallback_location: admin_root_path, notice: I18n.t("active_admin.favorites.layout_saved")
          end

          page_action :reset, method: :delete do
            authorize_view_lens_page_action!(:reset)
            user = send(ActiveAdmin::Favorites.config.current_user_method)
            record = ViewLensDefault.for_user(
              user,
              resource_key: params.fetch(:resource_key),
              action: params.fetch(:view_lens_action)
            )
            record&.destroy
            redirect_back fallback_location: admin_root_path, notice: I18n.t("active_admin.favorites.layout_reset")
          end

          page_action :save_lens_favorite, method: :post do
            authorize_view_lens_page_action!(:save_lens_favorite)
            user = send(ActiveAdmin::Favorites.config.current_user_method)
            bookmark = LensFavorite.new(
              name: params.fetch(:name),
              resource_key: params.fetch(:resource_key),
              path: params.fetch(:path),
              action: params.fetch(:view_lens_action),
              layout: ActiveAdmin::Favorites::RegisterViewLensPreferences.parse_layout_param(params[:layout]),
              published: ActiveModel::Type::Boolean.new.cast(params[:published]) || false
            )
            bookmark.public_send(:"#{ActiveAdmin::Favorites.config.user_foreign_key}=", user.id)

            if bookmark.save
              redirect_to admin_favorites_path(kind: "lens"), notice: I18n.t("active_admin.favorites.lens_created")
            else
              redirect_back fallback_location: admin_root_path, alert: bookmark.errors.full_messages.to_sentence
            end
          end
        end
      end

      def page_registered?
        ActiveAdmin.application.namespace(ActiveAdmin::Favorites.config.namespace_name)
          .resources.any? { |resource| resource.is_a?(ActiveAdmin::Page) && resource.name == PAGE_NAME }
      end
    end
  end
end
