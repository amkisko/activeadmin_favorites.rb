# frozen_string_literal: true

module ActiveAdmin
  module Favorites
    class Engine < ::Rails::Engine
      engine_name "activeadmin_favorites"

      initializer "activeadmin_favorites.load_lib" do
        require "activeadmin/favorites/migration_helpers"
        require "activeadmin/favorites/migration_support"
        require "activeadmin/favorites/view_lens/current"
        require "activeadmin/favorites/user_record"
        require "activeadmin/favorites/view_lens"
        require "activeadmin/favorites/hash_coercion"
        require "activeadmin/favorites/view_lens/applicator"
        require "activeadmin/favorites/view_lens/catalog"
        require "activeadmin/favorites/view_lens/patches"
        require "activeadmin/favorites/view_lens/resource_dsl"
        require "activeadmin/favorites/install"
        require "activeadmin/favorites/register_favorites"
        require "activeadmin/favorites/register_view_lens_preferences"
      end

      initializer "activeadmin_favorites.assets" do |app|
        assets_path = root.join("app/assets")
        app.config.importmap.cache_sweepers << assets_path.join("controllers") if app.config.respond_to?(:importmap)

        next unless app.config.respond_to?(:assets)

        app.config.assets.precompile << "activeadmin_favorites/personalization_controller.js"
      end

      initializer "activeadmin_favorites.importmap", after: :importmap do
        pin_controller = proc do |importmap|
          importmap.pin "controllers/activeadmin_favorites/personalization_controller",
            to: "activeadmin_favorites/personalization_controller.js"
        end

        application_importmap = Rails.application.importmap if Rails.application.respond_to?(:importmap)
        application_importmap&.draw(&pin_controller)
        ActiveAdmin.importmap.draw(&pin_controller) if defined?(ActiveAdmin) && ActiveAdmin.respond_to?(:importmap)
      end

      initializer "activeadmin_favorites.i18n" do
        I18n.load_path << root.join("config/locales/activeadmin_favorites.en.yml")
      end

      initializer "activeadmin_favorites.append_migrations" do |app|
        ActiveAdmin::Favorites::MigrationHelpers.append_engine_migrations!(app)
      end

      rake_tasks do
        load root.join("lib/tasks/activeadmin_favorites_tasks.rake")
      end

      initializer "activeadmin_favorites.after_load", after: :load_config_initializers do
        next unless defined?(ActiveAdmin) && ActiveAdmin.respond_to?(:after_load)

        ActiveAdmin.after_load do
          ActiveAdmin::Favorites.register_resources!
          ActiveAdmin::Favorites.install!
        end
      end

      config.to_prepare do
        next unless defined?(ActiveAdmin::ResourceController)

        ActiveAdmin::Favorites::Favorite.define_favorites_user_association!
        ActiveAdmin::Favorites::ViewLensDefault.define_favorites_user_association!
        ActiveAdmin::Favorites.register_resources!
        ActiveAdmin::Favorites.install!
      end
    end
  end
end
