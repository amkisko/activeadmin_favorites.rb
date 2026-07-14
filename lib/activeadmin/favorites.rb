# frozen_string_literal: true

require "activeadmin/favorites/version"
require "activeadmin/favorites/configuration"

module ActiveAdmin
  module Favorites
    class << self
      def config
        @config ||= Configuration.new
      end

      def configure
        yield config
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
