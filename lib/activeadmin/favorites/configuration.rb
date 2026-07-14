# frozen_string_literal: true

module ActiveAdmin
  module Favorites
    class Configuration
      attr_accessor :user_class,
        :user_foreign_key,
        :user_association_name,
        :user_label_method,
        :current_user_method,
        :stimulus_controller,
        :namespace_name,
        :table_name

      def initialize
        @user_class = "User"
        @user_foreign_key = :user_id
        @user_association_name = :user
        @user_label_method = :email
        @current_user_method = :current_user
        @stimulus_controller = "activeadmin-favorites--personalization"
        @namespace_name = :admin
        @table_name = "admin_favorites"
      end

      def namespace_path_prefix
        "/#{namespace_name}/"
      end
    end
  end
end
