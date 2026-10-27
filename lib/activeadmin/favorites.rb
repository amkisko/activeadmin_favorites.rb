# frozen_string_literal: true

require "activeadmin/favorites/version"
require "activeadmin/favorites/configuration"

module ActiveAdmin
  module Favorites
    PERSONALIZATION_MENU_STYLESHEET = "activeadmin_favorites/personalization_menu"

    class << self
      def config
        @config ||= Configuration.new
      end

      def configure
        yield config
      end

      # Absolute path to the plain CSS file Propshaft serves. Hosts that
      # concatenate into a Tailwind CLI entry can File.read this path; do not
      # bare-@import the Propshaft logical path from a tmp Tailwind input.
      def personalization_menu_stylesheet_path
        Engine.root.join("app/assets/stylesheets/#{PERSONALIZATION_MENU_STYLESHEET}.css")
      end

      def install!
        require "activeadmin/favorites/install"
        Install.call
      end

      def register_resources!
        require "activeadmin/favorites/register_favorites"
        require "activeadmin/favorites/register_view_lens_preferences"
        RegisterFavorites.call
        RegisterViewLensPreferences.call
      end
    end
  end
end
