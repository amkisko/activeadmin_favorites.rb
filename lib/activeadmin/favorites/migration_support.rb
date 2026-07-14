# frozen_string_literal: true

module ActiveAdmin
  module Favorites
    module MigrationSupport
      def favorites_user_foreign_key
        ActiveAdmin::Favorites.config.user_foreign_key
      end

      def favorites_json_column_type
        postgresql_adapter? ? :jsonb : :json
      end

      def postgresql_adapter?
        connection.adapter_name.match?(/postgresql/i)
      end
    end
  end
end
