# frozen_string_literal: true

module ActiveAdmin
  module Favorites
    module ViewLens
      module ControllerMethods
        extend ActiveSupport::Concern

        included do
          before_action :apply_active_admin_favorites_lens, only: [:index, :show]
          after_action :clear_active_admin_favorites_lens, only: [:index, :show]

          helper_method :active_admin_favorites_catalog, :active_admin_favorites_layout
        end

        def clear_active_admin_favorites_lens
          ViewLens::Applicator.reset!
        end

        def apply_active_admin_favorites_lens
          return if active_admin_config.resource_class == Favorite

          ViewLens::Applicator.resolve_layout(controller: self)
        end

        def active_admin_favorites_catalog
          context = ViewLens::Current.catalog_context
          return ViewLens::Applicator.current_catalog if ViewLens::Applicator.current_catalog.present?
          return [] unless context

          ViewLens::Applicator.build_catalog(
            active_admin_config: context[:active_admin_config],
            action: context[:action],
            render_context: context[:render_context]
          )
        end

        def active_admin_favorites_layout
          ViewLens::Applicator.current_layout
        end
      end
    end
  end
end
