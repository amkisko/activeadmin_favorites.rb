# frozen_string_literal: true

require "rails_helper"

RSpec.describe ActiveAdmin::Favorites::Favorite do
  include ActiveSupport::Testing::TimeHelpers

  describe ".sanitize_query_string" do
    it "removes commit from the query string" do
      sanitized = described_class.sanitize_query_string("order=id_desc&commit=Filter&q%5Bcreated_at_gteq%5D=2026-05-01")

      expect(sanitized).to include("order=id_desc")
      expect(sanitized).to include("created_at_gteq")
      expect(sanitized).not_to include("commit")
    end
  end

  describe ".visible_to" do
    it "returns personal and shared favorites for the user" do
      user = create(:user)
      other_user = create(:user)
      personal = create(:filters_favorite, user: user, name: "Personal", query_string: "order=id_desc")
      shared = create(:filters_favorite, user: other_user, name: "Shared", published: true, query_string: "order=id_desc")
      create(:filters_favorite, user: other_user, name: "Private", query_string: "order=title_asc")

      expect(described_class.visible_to(user)).to contain_exactly(personal, shared)
    end
  end

  describe "duplicate favorites" do
    it "rejects the same path, query string, and type for one user" do
      user = create(:user)
      create(:filters_favorite, user: user, path: "/admin/articles", query_string: "order=id_desc")

      duplicate = build(:filters_favorite, user: user, path: "/admin/articles", query_string: "order=id_desc")

      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:base]).to be_present
    end

    it "allows the same path and query string for different users" do
      first_user = create(:user)
      second_user = create(:user)
      create(:filters_favorite, user: first_user, path: "/admin/articles", query_string: "order=id_desc")

      duplicate = build(:filters_favorite, user: second_user, path: "/admin/articles", query_string: "order=id_desc")

      expect(duplicate).to be_valid
    end
  end

  describe "path validation" do
    around do |example|
      original_namespace = ActiveAdmin::Favorites.config.namespace_name
      example.run
    ensure
      ActiveAdmin::Favorites.configure { |configuration| configuration.namespace_name = original_namespace }
    end

    it "accepts paths under the configured namespace" do
      favorite = build(:filters_favorite, path: "/admin/articles")

      expect(favorite).to be_valid
    end

    it "rejects paths outside the configured namespace" do
      ActiveAdmin::Favorites.configure { |configuration| configuration.namespace_name = :backoffice }

      favorite = build(:filters_favorite, path: "/admin/articles")

      expect(favorite).not_to be_valid
      expect(favorite.errors[:path]).to be_present
    end
  end

  describe "published_at" do
    it "is set when the bookmark is published" do
      bookmark = create(:filters_favorite, published: true)

      expect(bookmark.published_at).to be_present
    end

    it "is cleared when the bookmark is unpublished" do
      bookmark = create(:filters_favorite, published: true)
      bookmark.update!(published: false)

      expect(bookmark.published_at).to be_nil
    end
  end

  describe "#index_url" do
    it "combines path and query string" do
      bookmark = build(:filters_favorite, path: "/admin/articles", query_string: "order=id_desc")

      expect(bookmark.index_url).to eq("/admin/articles?order=id_desc")
    end

    it "resolves dynamic date macros when building the url" do
      travel_to Time.zone.parse("2026-06-15 12:00:00") do
        bookmark = build(
          :filters_favorite,
          path: "/admin/articles",
          query_string: "order=id_desc&q%5Bstatus_eq%5D=draft",
          macros: [
            {"type" => "template", "name" => "previous_calendar_month", "attribute" => "created_at"}
          ]
        )

        expect(bookmark.index_url).to include("created_at_gteq%5D=2026-05-01")
        expect(bookmark.index_url).to include("created_at_lteq%5D=2026-05-31")
        expect(bookmark.index_url).to include("status_eq")
      end
    end
  end

  describe "#assign_macros_from_form!" do
    it "stores macros and strips managed keys from query_string" do
      bookmark = build(
        :filters_favorite,
        resource_key: "articles",
        query_string: "q%5Bcreated_at_gteq%5D=2026-05-01&q%5Bcreated_at_lteq%5D=2026-05-31&q%5Bstatus_eq%5D=draft"
      )

      expect(
        bookmark.assign_macros_from_form!(
          template_assignments: {
            "0" => {"enabled" => "1", "attribute" => "created_at", "name" => "previous_calendar_month"}
          },
          macros_json: nil,
          use_advanced_macros: false
        )
      ).to be(true)

      expect(bookmark.macros).to eq(
        [{"type" => "template", "name" => "previous_calendar_month", "attribute" => "created_at"}]
      )
      expect(bookmark.query_string).to include("status_eq")
      expect(bookmark.query_string).not_to include("created_at_gteq")
    end
  end
end
