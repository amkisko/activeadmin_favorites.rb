# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Favorite form UX", type: :request do
  let(:user) { create(:user) }

  before { sign_in(user) }

  it "does not mark published as required on the new form", :aggregate_failures do
    get new_admin_favorite_path(
      path: "/admin/articles",
      query_string: "order=id_desc",
      resource_key: "articles",
      action_name: "index"
    )

    expect(response).to have_http_status(:ok)
    published_input = response.body[/<li[^>]*id="favorite_published_input"[^>]*>.*?<\/li>/m]
    expect(published_input).to be_present
    expect(published_input).not_to include("required")
    expect(published_input).not_to include("<abbr")
  end

  it "hides macros JSON until advanced mode is checked", :aggregate_failures do
    get new_admin_favorite_path(
      path: "/admin/articles",
      query_string: "order=id_desc&q%5Bcreated_at_gteq%5D=2026-05-01&q%5Bcreated_at_lteq%5D=2026-05-31",
      resource_key: "articles",
      action_name: "index"
    )

    expect(response).to have_http_status(:ok)
    expect(response.body).to include(%(data-controller="activeadmin-favorites--macro-fields"))
    expect(response.body).to include(%(id="favorite_macros_json"))
    expect(response.body).to match(/id="favorite_macros_json"[^>]*\bhidden(?:="hidden")?/)
    expect(response.body).to include("activeadmin-favorites--macro-fields#toggle")
  end

  it "omits dynamic filter panels on create when no date ranges are detected" do
    get new_admin_favorite_path(
      path: "/admin/articles",
      query_string: "order=id_desc",
      resource_key: "articles",
      action_name: "index"
    )

    expect(response).to have_http_status(:ok)
    expect(response.body).not_to include(I18n.t("active_admin.favorites.macros_panel"))
    expect(response.body).not_to include(I18n.t("active_admin.favorites.advanced_macros"))
  end
end
