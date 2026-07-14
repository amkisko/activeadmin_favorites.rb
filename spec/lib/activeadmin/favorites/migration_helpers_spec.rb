# frozen_string_literal: true

require "rails_helper"

RSpec.describe ActiveAdmin::Favorites::MigrationHelpers do
  describe ".engine_migration_paths" do
    it "lists view lens defaults and admin_favorites migrations only" do
      basenames = described_class.engine_migration_paths.map { |path| File.basename(path) }

      expect(basenames).to eq(
        [
          "20260709100000_create_active_admin_view_lens_defaults.rb",
          "20260709130000_create_admin_favorites.rb"
        ]
      )
    end
  end
end
