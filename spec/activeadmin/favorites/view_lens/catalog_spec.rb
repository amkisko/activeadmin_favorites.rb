# frozen_string_literal: true

require "rails_helper"

RSpec.describe ActiveAdmin::Favorites::ViewLens::Catalog do
  let(:active_admin_config) do
    instance_double(
      ActiveAdmin::Resource,
      resource_name: double(route_key: "articles"),
      filters_enabled?: false,
      filters: {},
      action_items: []
    )
  end

  after do
    ActiveAdmin::Favorites::ViewLens::Applicator.reset!
  end

  it "includes registered show rows in show catalog entries" do
    ActiveAdmin::Favorites::ViewLens::Applicator.register_row(
      resource_key: "articles",
      id: "external_id",
      label: "External ID"
    )

    entries = described_class.for(active_admin_config: active_admin_config, action: "show")

    expect(entries.map(&:group)).to include("show_rows")
    expect(entries.find { |entry| entry.id == "external_id" }.label).to eq("External ID")
  end
end
