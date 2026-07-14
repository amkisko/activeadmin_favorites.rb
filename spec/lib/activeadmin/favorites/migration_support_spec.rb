# frozen_string_literal: true

require "rails_helper"

RSpec.describe ActiveAdmin::Favorites::MigrationSupport do
  let(:migration) do
    Class.new do
      include ActiveAdmin::Favorites::MigrationSupport

      attr_reader :connection
      attr_writer :connection
    end.new
  end

  describe "#favorites_json_column_type" do
    it "uses jsonb on PostgreSQL" do
      migration.connection = instance_double(
        ActiveRecord::ConnectionAdapters::AbstractAdapter,
        adapter_name: "PostgreSQL"
      )

      expect(migration.favorites_json_column_type).to eq(:jsonb)
    end

    it "uses json on SQLite" do
      migration.connection = instance_double(
        ActiveRecord::ConnectionAdapters::AbstractAdapter,
        adapter_name: "SQLite"
      )

      expect(migration.favorites_json_column_type).to eq(:json)
    end
  end

  describe "#favorites_user_foreign_key" do
    it "reads the configured foreign key" do
      ActiveAdmin::Favorites.configure { |configuration| configuration.user_foreign_key = :account_id }

      expect(migration.favorites_user_foreign_key).to eq(:account_id)
    ensure
      ActiveAdmin::Favorites.configure { |configuration| configuration.user_foreign_key = :user_id }
    end
  end
end
