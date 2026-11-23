# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Favorite blank create form", type: :request do
  let(:user) { create(:user) }

  before { sign_in(user) }

  def path_input(html)
    html[%r{<(?:input|textarea)[^>]*\bid="favorite_path"[^>]*>}i]
  end

  def resource_key_input(html)
    html[%r{<(?:input|textarea)[^>]*\bid="favorite_resource_key"[^>]*>}i]
  end

  it "exposes editable path and resource_key when create context is missing", :aggregate_failures do
    get new_admin_favorite_path

    expect(response).to have_http_status(:ok)

    path_field = path_input(response.body)
    resource_key_field = resource_key_input(response.body)
    expect(path_field).to be_present
    expect(resource_key_field).to be_present
    expect(path_field).not_to match(/\btype=["']hidden["']/i)
    expect(resource_key_field).not_to match(/\btype=["']hidden["']/i)
    expect(response.body).to include(%(name="commit"))
  end

  it "keeps destination fields hidden when create context is prefilled", :aggregate_failures do
    get new_admin_favorite_path(
      path: "/admin/articles",
      query_string: "order=id_desc",
      resource_key: "articles",
      action_name: "index"
    )

    expect(response).to have_http_status(:ok)

    path_field = path_input(response.body)
    resource_key_field = resource_key_input(response.body)
    expect(path_field).to be_present
    expect(resource_key_field).to be_present
    expect(path_field).to match(/\btype=["']hidden["']/i)
    expect(resource_key_field).to match(/\btype=["']hidden["']/i)
  end

  it "creates a favorite from a blank new form when required destination fields are supplied" do
    expect {
      post admin_favorites_path, params: {
        favorite: {
          name: "Manual favorite",
          path: "/admin/articles",
          query_string: "order=id_desc",
          resource_key: "articles",
          kind: "filters",
          action: "index"
        }
      }
    }.to change { ActiveAdmin::Favorites::Favorite.where(user: user).count }.by(1)

    expect(response).to redirect_to(admin_favorites_path(kind: "filters"))
  end

  it "redisplays submitted values when path or resource_key is still missing", :aggregate_failures do
    post admin_favorites_path, params: {
      favorite: {
        name: "Incomplete favorite",
        path: "",
        resource_key: "",
        kind: "filters"
      }
    }

    expect(response).to have_http_status(:unprocessable_content)
    expect(response.body).to include("Incomplete favorite")
    expect(ActiveAdmin::Favorites::Favorite.where(user: user, name: "Incomplete favorite")).to be_empty

    path_field = path_input(response.body)
    resource_key_field = resource_key_input(response.body)
    expect(path_field).to be_present
    expect(resource_key_field).to be_present
    expect(path_field).not_to match(/\btype=["']hidden["']/i)
    expect(resource_key_field).not_to match(/\btype=["']hidden["']/i)
  end
end
