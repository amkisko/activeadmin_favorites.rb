# frozen_string_literal: true

require "rails_helper"

RSpec.describe "View lens preferences page actions", type: :request do
  let(:user) { create(:user) }

  before { sign_in(user) }

  it "updates the user's default layout" do
    layout = {"hidden" => {"columns" => ["status"]}}

    patch admin_viewlenspreferences_update_path, params: {
      resource_key: "articles",
      view_lens_action: "index",
      layout: layout.to_json
    }

    expect(response).to redirect_to(admin_root_path)
    record = ActiveAdmin::Favorites::ViewLensDefault.for_user(user, resource_key: "articles", action: "index")
    expect(record.layout.dig("hidden", "columns")).to eq(["status"])
  end

  it "resets the user's default layout" do
    ActiveAdmin::Favorites::ViewLensDefault.upsert_for!(
      user: user,
      resource_key: "articles",
      action: "index",
      layout: {"hidden" => {"columns" => ["status"]}}
    )

    delete admin_viewlenspreferences_reset_path, params: {
      resource_key: "articles",
      view_lens_action: "index"
    }

    expect(response).to redirect_to(admin_root_path)
    expect(
      ActiveAdmin::Favorites::ViewLensDefault.for_user(user, resource_key: "articles", action: "index")
    ).to be_nil
  end

  it "creates a lens favorite from the personalization flow" do
    post admin_viewlenspreferences_save_lens_favorite_path, params: {
      name: "Articles layout",
      resource_key: "articles",
      path: "/admin/articles",
      view_lens_action: "index",
      layout: {"hidden" => {"columns" => ["status"]}}.to_json,
      published: false
    }

    expect(response).to redirect_to(admin_favorites_path(kind: "lens"))
    bookmark = ActiveAdmin::Favorites::LensFavorite.find_by!(name: "Articles layout", user_id: user.id)
    expect(bookmark.layout.dig("hidden", "columns")).to eq(["status"])
  end
end
