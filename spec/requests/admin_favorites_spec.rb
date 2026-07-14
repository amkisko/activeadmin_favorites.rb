# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Admin favorites", type: :request do
  it "lists favorites for the current user" do
    user = create(:user)
    favorite = create(:filters_favorite, user: user, name: "Articles scope")

    get admin_favorites_path

    expect(response).to have_http_status(:ok)
    expect(response.body).to include("Articles scope")
  end

  it "ignores an invalid kind tab parameter" do
    create(:filters_favorite, name: "Visible favorite")

    get admin_favorites_path(kind: "not_a_kind")

    expect(response).to have_http_status(:ok)
    expect(response.body).to include("Visible favorite")
  end

  it "offers edit for the owner's filter favorite on the matching index" do
    owner = create(:user)
    sign_in(owner)
    bookmark = create(:filters_favorite, user: owner, query_string: "order=id_desc")

    get admin_articles_path(order: "id_desc")

    expect(response).to have_http_status(:ok)
    expect(response.body).to include(edit_admin_favorite_path(bookmark))
  end

  it "does not offer edit for another user's published filter favorite" do
    owner = create(:user)
    viewer = create(:user)
    sign_in(viewer)
    bookmark = create(:filters_favorite, user: owner, published: true, query_string: "order=id_desc")

    get admin_articles_path(order: "id_desc")

    expect(response).to have_http_status(:ok)
    expect(response.body).not_to include(edit_admin_favorite_path(bookmark))
  end

  it "rejects creating a duplicate filter favorite for the same user" do
    user = create(:user)
    sign_in(user)
    create(:filters_favorite, user: user, path: "/admin/articles", query_string: "order=id_desc", name: "Existing")

    post admin_favorites_path, params: {
      favorite: {
        name: "Duplicate",
        path: "/admin/articles",
        query_string: "order=id_desc",
        resource_key: "articles",
        kind: "filters"
      }
    }

    expect(response).to have_http_status(:unprocessable_entity)
    expect(ActiveAdmin::Favorites::Favorite.where(user: user, path: "/admin/articles", query_string: "order=id_desc").count).to eq(1)
  end

  it "preloads favorite owners on the index" do
    owner = create(:user)
    3.times do |index|
      create(:filters_favorite, user: owner, query_string: "order=id_desc&q%5Btitle_cont%5D=article#{index}")
    end

    user_queries = []
    subscriber = ActiveSupport::Notifications.subscribe("sql.active_record") do |*, payload|
      next if payload[:name] == "SCHEMA"

      user_queries << payload[:sql] if payload[:sql].match?(/\bFROM\s+"users"/i)
    end

    get admin_favorites_path

    ActiveSupport::Notifications.unsubscribe(subscriber)

    expect(response).to have_http_status(:ok)
    expect(user_queries.size).to be < 3
  end
end
