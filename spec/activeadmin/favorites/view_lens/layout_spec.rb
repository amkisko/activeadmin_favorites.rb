# frozen_string_literal: true

require "rails_helper"

RSpec.describe ActiveAdmin::Favorites::ViewLens::Layout do
  describe ".normalize" do
    it "fills version and hidden groups" do
      layout = described_class.normalize(hidden: {columns: ["created_at"]})

      expect(layout["version"]).to eq(1)
      expect(layout.dig("hidden", "columns")).to eq(["created_at"])
      expect(layout.dig("hidden", "filters")).to eq([])
    end
  end

  describe "#hidden_column?" do
    it "matches string ids" do
      layout = described_class.new(hidden: {columns: ["created_at"]})

      expect(layout).to be_hidden_column("created_at")
      expect(layout).not_to be_hidden_column("status")
    end
  end

  describe "#merge" do
    it "combines hidden ids without duplicates" do
      left = described_class.new(hidden: {columns: ["created_at"]})
      right = described_class.new(hidden: {columns: %w[created_at status]})

      merged = left.merge(right)

      expect(merged.hidden_columns).to contain_exactly("created_at", "status")
    end
  end
end
