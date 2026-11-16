# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Favorites GraphQL surface", type: :request do
  it "exposes favorites queries and mutations on the admin schema", :aggregate_failures do
    data = gql!(<<~GQL)
      {
        queryFields: __type(name: "Query") { fields { name } }
        mutationFields: __type(name: "Mutation") { fields { name } }
        favoriteType: __type(name: "Favorite") { fields { name } }
      }
    GQL

    expect(response).to have_http_status(:ok)
    expect(data["errors"]).to be_nil

    queries = data.dig("data", "queryFields", "fields").map { |field| field.fetch("name") }
    mutations = data.dig("data", "mutationFields", "fields").map { |field| field.fetch("name") }
    fields = data.dig("data", "favoriteType", "fields").map { |field| field.fetch("name") }

    expect(queries).to include("favorites", "favorite")
    expect(mutations).to include("create_favorite", "update_favorite", "delete_favorite")
    expect(fields).to include("id", "name", "path", "query_string", "resource_key", "published", "macros", "layout")
  end

  it "lists and reads a saved filter favorite", :aggregate_failures do
    user = create(:user)
    sign_in(user)
    bookmark = create(
      :filters_favorite,
      user: user,
      name: "Articles order",
      path: "/admin/articles",
      query_string: "order=id_desc",
      resource_key: "articles"
    )

    list = gql!(<<~GQL)
      {
        favorites {
          nodes {
            id
            name
            path
            query_string
            resource_key
            published
          }
        }
      }
    GQL

    expect(list["errors"]).to be_nil
    node = list.dig("data", "favorites", "nodes").find { |row| row["id"] == bookmark.id.to_s }
    expect(node).to include(
      "name" => "Articles order",
      "path" => "/admin/articles",
      "query_string" => "order=id_desc",
      "resource_key" => "articles",
      "published" => false
    )

    show = gql!(<<~GQL)
      {
        favorite(where: { id: "#{bookmark.id}" }) {
          id
          name
          macros
          layout
        }
      }
    GQL

    expect(show["errors"]).to be_nil
    expect(show.dig("data", "favorite", "name")).to eq("Articles order")
    expect(show.dig("data", "favorite", "macros")).to eq([])
  end

  it "creates a private filter favorite through GraphQL", :aggregate_failures do
    user = create(:user)
    sign_in(user)

    expect {
      data = gql!(<<~GQL)
        mutation {
          create_favorite(input: {
            name: "GraphQL bookmark"
            path: "/admin/articles"
            query_string: "order=id_asc"
            resource_key: "articles"
            published: false
          }) {
            id
            name
            path
            query_string
          }
        }
      GQL

      expect(data["errors"]).to be_nil
      expect(data.dig("data", "create_favorite", "name")).to eq("GraphQL bookmark")
      expect(data.dig("data", "create_favorite", "path")).to eq("/admin/articles")
      expect(data.dig("data", "create_favorite", "query_string")).to eq("order=id_asc")
    }.to change(ActiveAdmin::Favorites::FiltersFavorite, :count).by(1)

    bookmark = ActiveAdmin::Favorites::FiltersFavorite.order(:id).last
    expect(bookmark.user_id).to eq(user.id)
    expect(bookmark.published).to be(false)
  end
end
