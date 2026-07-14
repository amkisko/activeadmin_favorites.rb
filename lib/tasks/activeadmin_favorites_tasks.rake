# frozen_string_literal: true

namespace :activeadmin_favorites do
  namespace :install do
    desc "Copy activeadmin_favorites migrations into db/migrate"
    task migrations: :environment do
      require "fileutils"
      require "activeadmin/favorites/migration_helpers"

      destination = Rails.root.join("db/migrate")
      FileUtils.mkdir_p(destination)

      copied = []
      skipped = []

      ActiveAdmin::Favorites::MigrationHelpers.engine_migration_paths.each do |source|
        target = destination.join(File.basename(source))
        version = File.basename(source).split("_", 2).first

        if target.exist?
          skipped << version
          next
        end

        FileUtils.cp(source, target)
        copied << version
      end

      if copied.any?
        puts "Copied migrations: #{copied.join(", ")}"
      else
        puts "No new migrations copied."
      end

      puts "Skipped existing versions: #{skipped.join(", ")}" if skipped.any?
      puts "Run bin/rails db:migrate when ready."
    end
  end
end
