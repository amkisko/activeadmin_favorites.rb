# frozen_string_literal: true

require "rails_helper"

RSpec.describe ActiveAdmin::Favorites::Favorite::MacroBuilder do
  describe ".from_template_assignments" do
    it "builds enabled template macros from form rows" do
      macros = described_class.from_template_assignments(
        {
          "0" => {"enabled" => "1", "attribute" => "created_at", "name" => "previous_calendar_month"},
          "1" => {"enabled" => "0", "attribute" => "updated_at", "name" => "current_calendar_month"}
        }
      )

      expect(macros).to eq(
        [{"type" => "template", "name" => "previous_calendar_month", "attribute" => "created_at"}]
      )
    end
  end
end
