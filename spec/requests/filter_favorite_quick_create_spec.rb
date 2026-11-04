# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Filter favorite quick create", type: :request do
  let(:user) { create(:user) }

  before { sign_in(user) }

  it "wires the star for quick create while keeping the full form as fallback", :aggregate_failures do
    get admin_articles_path(order: "id_desc")

    expect(response).to have_http_status(:ok)
    expect(response.body).to include(%(data-testid="filter-favorite"))
    expect(response.body).to include(%(data-controller="activeadmin-favorites--filter-favorite"))
    expect(response.body).to include(quick_create_admin_favorites_path)
    expect(response.body).to include("/admin/favorites/new?")
    expect(response.body).to include("query_string=order%3Did_desc")
    expect(response.body).to include("resource_key=articles")
  end

  it "creates a private filter favorite from the star path without the full form", :aggregate_failures do
    expect {
      post quick_create_admin_favorites_path, params: {
        path: "/admin/articles",
        query_string: "order=id_desc",
        resource_key: "articles",
        action_name: "index"
      }
    }.to change(ActiveAdmin::Favorites::FiltersFavorite, :count).by(1)

    bookmark = ActiveAdmin::Favorites::FiltersFavorite.order(:id).last
    expect(bookmark.user_id).to eq(user.id)
    expect(bookmark.published).to be(false)
    expect(bookmark.path).to eq("/admin/articles")
    expect(bookmark.query_string).to eq("order=id_desc")
    expect(bookmark.name).to be_present
    expect(response).to redirect_to("/admin/articles?order=id_desc")
  end

  it "rejects a duplicate quick create for the same filters", :aggregate_failures do
    create(:filters_favorite, user: user, path: "/admin/articles", query_string: "order=id_desc")

    expect {
      post quick_create_admin_favorites_path, params: {
        path: "/admin/articles",
        query_string: "order=id_desc",
        resource_key: "articles",
        action_name: "index"
      }
    }.not_to change(ActiveAdmin::Favorites::FiltersFavorite, :count)

    expect(response).to redirect_to("/admin/articles?order=id_desc")
    expect(flash[:alert]).to be_present
  end
end
