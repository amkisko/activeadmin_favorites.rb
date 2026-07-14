# frozen_string_literal: true

module ActiveAdmin
  module Favorites
    module MigrationHelpers
      module_function

      def engine_migration_paths
        root = ActiveAdmin::Favorites::Engine.root
        Dir[root.join("db/migrate/*.rb")].sort
      end

      def host_migration_versions(app_root)
        Dir[app_root.join("db/migrate/*.rb")].map { |path| File.basename(path).split("_", 2).first }
      end

      def append_engine_migrations!(app)
        return if app.root.to_s.start_with?(ActiveAdmin::Favorites::Engine.root.to_s)

        host_versions = host_migration_versions(app.root)
        paths = app.config.paths["db/migrate"]
        return if paths.frozen?

        engine_migration_paths.each do |migration_path|
          version = File.basename(migration_path).split("_", 2).first
          next if host_versions.include?(version)
          next if paths.include?(migration_path)

          paths << migration_path
        end
      end
    end
  end
end
