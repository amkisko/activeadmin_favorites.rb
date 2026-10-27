# frozen_string_literal: true

require "rails_helper"

RSpec.describe ActiveAdmin::Favorites do
  describe ".personalization_menu_stylesheet_path" do
    it "points at the shipped Propshaft stylesheet file" do
      path = described_class.personalization_menu_stylesheet_path

      expect(path).to be_a(Pathname)
      expect(path).to be_file
      expect(path.basename.to_s).to eq("personalization_menu.css")
      expect(path.read).to include(".favorites-personalization-menu__catalog")
    end
  end
end
