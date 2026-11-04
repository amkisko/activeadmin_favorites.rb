# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Filter favorite action item", type: :request do
  it "renders an icon button with the add-favorite accessible name", :aggregate_failures do
    get admin_articles_path

    expect(response).to have_http_status(:ok)
    expect(response.body).to include(%(data-testid="filter-favorite"))
    expect(response.body).to include(%(data-favorited="false"))
    expect(response.body).to include(%(aria-label="#{I18n.t("active_admin.favorites.add_favorite")}"))
    expect(response.body).to include(%(<span class="sr-only">#{I18n.t("active_admin.favorites.add_favorite")}</span>))
  end

  it "renders a filled star and edit label for an owned filter favorite", :aggregate_failures do
    owner = create(:user)
    sign_in(owner)
    bookmark = create(:filters_favorite, user: owner, query_string: "order=id_desc")

    get admin_articles_path(order: "id_desc")

    expect(response).to have_http_status(:ok)
    expect(response.body).to include(%(data-testid="filter-favorite"))
    expect(response.body).to include(%(data-favorited="true"))
    expect(response.body).to include(%(aria-label="#{I18n.t("active_admin.favorites.edit_favorite")}"))
    expect(response.body).to include(edit_admin_favorite_path(bookmark))
  end
end
