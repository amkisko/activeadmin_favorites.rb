# frozen_string_literal: true

require "rails/generators/base"

module ActiveadminFavorites
  class InstallGenerator < Rails::Generators::Base
    source_root File.expand_path("install/templates", __dir__)

    desc "Install activeadmin_favorites initializer, policy, and locale template"

    def copy_initializer
      template "initializer.rb", "config/initializers/activeadmin_favorites.rb"
    end

    def copy_policy
      template "favorite_policy.rb", "app/policies/active_admin/favorites/favorite_policy.rb"
    end

    def copy_locale_template
      template "locale.en.yml", "config/locales/activeadmin_favorites.en.yml"
    end

    def install_migrations
      rake "activeadmin_favorites:install:migrations"
    end

    def show_page_policy_note
      say <<~NOTE, :yellow

        Add save_lens_favorite? and reset? to your ActiveAdmin::PagePolicy (or equivalent)
        so view lens preference page actions authorize correctly.

        Copy active_admin.favorites keys into your fi/sv locale files if needed.
      NOTE
    end
  end
end
