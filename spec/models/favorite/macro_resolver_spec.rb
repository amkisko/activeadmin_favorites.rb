# frozen_string_literal: true

require "rails_helper"

RSpec.describe ActiveAdmin::Favorites::Favorite::MacroResolver do
  include ActiveSupport::Testing::TimeHelpers

  describe ".call" do
    it "resolves previous calendar month for an attribute" do
      travel_to Time.zone.parse("2026-06-15 12:00:00") do
        result = described_class.call(
          macros: [
            {"type" => "template", "name" => "previous_calendar_month", "attribute" => "created_at"}
          ]
        )

        expect(result).to eq(
          "created_at_gteq" => "2026-05-01",
          "created_at_lteq" => "2026-05-31"
        )
      end
    end

    it "resolves advanced relative_time_bound macros" do
      travel_to Time.zone.parse("2026-06-15 12:00:00") do
        result = described_class.call(
          macros: [
            {
              "type" => "relative_time_bound",
              "attribute" => "updated_at",
              "predicate" => "gteq",
              "anchor" => "beginning_of_unit",
              "unit" => "month",
              "offset" => -1
            }
          ]
        )

        expect(result).to eq("updated_at_gteq" => "2026-05-01")
      end
    end
  end
end
