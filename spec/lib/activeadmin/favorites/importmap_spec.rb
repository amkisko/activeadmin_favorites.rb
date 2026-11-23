# frozen_string_literal: true

require "rails_helper"

RSpec.describe ActiveAdmin::Favorites::Engine do
  DESK_CONTROLLER_KEYS = [
    "controllers/activeadmin_favorites/personalization_controller",
    "controllers/activeadmin_favorites/filter_favorite_controller",
    "controllers/activeadmin_favorites/macro_fields_controller"
  ].freeze

  it "pins desk Stimulus controllers on ActiveAdmin.importmap only", :aggregate_failures do
    expect(ActiveAdmin).to respond_to(:importmap)

    DESK_CONTROLLER_KEYS.each do |key|
      expect(ActiveAdmin.importmap.packages.keys).to include(key)
    end

    expect(Rails.application).to respond_to(:importmap)
    DESK_CONTROLLER_KEYS.each do |key|
      expect(Rails.application.importmap.packages.keys).not_to include(key)
    end
  end
end
