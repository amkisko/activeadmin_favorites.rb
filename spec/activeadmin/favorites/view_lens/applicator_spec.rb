# frozen_string_literal: true

require "rails_helper"

RSpec.describe ActiveAdmin::Favorites::ViewLens::Applicator do
  after do
    described_class.reset!
  end

  it "keeps layout state isolated per request current attributes reset" do
    described_class.current_layout = ActiveAdmin::Favorites::ViewLens::Layout.new(
      "hidden" => {"columns" => ["created_at"]}
    )

    described_class.reset!

    expect(described_class.current_layout.layout.dig("hidden", "columns")).to eq([])
  end

  it "clears registered columns on reset" do
    described_class.register_column(resource_key: "articles", id: "status", label: "Status")

    described_class.reset!

    expect(described_class.registered_columns["articles"]).to eq([])
  end

  describe ".resolve_layout" do
    let(:user) { create(:user) }
    let(:controller) do
      instance_double(
        ActionController::Base,
        action_name: "index",
        params: ActionController::Parameters.new,
        helpers: instance_double(ActionView::Base)
      ).tap do |double_controller|
        allow(double_controller).to receive(:send).with(:current_user).and_return(user)
        allow(double_controller).to receive(:send).with(:active_admin_config).and_return(
          instance_double(ActiveAdmin::Resource, resource_name: instance_double(ActiveAdmin::Resource::Name, route_key: "articles"))
        )
      end
    end

    it "ignores favorite layout when resource_key does not match" do
      bookmark = ActiveAdmin::Favorites::LensFavorite.create!(
        user: user,
        name: "Users lens",
        resource_key: "users",
        path: "/admin/users",
        action: "index",
        layout: {"hidden" => {"columns" => ["email"]}}
      )

      layout = described_class.resolve_layout(controller: controller)

      expect(layout.hidden_columns).not_to include("email")
      expect(bookmark.id).to be_present
    end

    it "merges favorite layout when resource_key and action match" do
      bookmark = ActiveAdmin::Favorites::LensFavorite.create!(
        user: user,
        name: "Articles lens",
        resource_key: "articles",
        path: "/admin/articles",
        action: "index",
        layout: {"hidden" => {"columns" => ["created_at"]}}
      )

      allow(controller).to receive(:params).and_return(ActionController::Parameters.new(favorite_id: bookmark.id))

      layout = described_class.resolve_layout(controller: controller)

      expect(layout.hidden_columns).to include("created_at")
    end
  end

  describe ".extract_column_id" do
    it "reads lens_id from column options" do
      column_id = described_class.extract_column_id([nil, {lens_id: "custom_column"}])

      expect(column_id).to eq("custom_column")
    end

    it "assigns stable ids to block columns without titles" do
      first_id = described_class.extract_column_id([nil, {}], resource_key: "articles")
      second_id = described_class.extract_column_id([nil, {}], resource_key: "articles")

      expect(first_id).to eq("block_column_1")
      expect(second_id).to eq("block_column_2")
    end
  end

  describe ".column_label_from_args" do
    it "labels block columns with a readable default" do
      label = described_class.column_label_from_args([nil, {}], column_id: "block_column_1")

      expect(label).to include("1")
    end
  end

  describe ".extract_row_id" do
    it "reads lens_id from row options" do
      row_id = described_class.extract_row_id("Title", {lens_id: "custom_row"})

      expect(row_id).to eq("custom_row")
    end
  end
end
