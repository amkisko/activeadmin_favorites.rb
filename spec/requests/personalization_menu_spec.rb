# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Personalization menu markup", type: :request do
  it "renders a scrollable catalog region with pinned actions", :aggregate_failures do
    get admin_articles_path

    expect(response).to have_http_status(:ok)
    expect(response.body).to include("favorites-personalization-menu__catalog")
    expect(response.body).to include("favorites-personalization-menu__actions")
    expect(response.body).to include("favorites-personalization-menu__action--wide")
    expect(response.body).to include(%(data-dropdown-toggle="personalization-menu-articles-index"))
  end

  it "links the personalization menu stylesheet when the host head includes it" do
    get admin_articles_path

    expect(response).to have_http_status(:ok)
    expect(response.body).to include("activeadmin_favorites/personalization_menu")
  end
end
