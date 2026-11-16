# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Favorites hub", type: :system do
  it "lists saved favorites and opens the matching filtered index", :aggregate_failures do
    user = create(:user)
    sign_in(user)
    create(
      :filters_favorite,
      user: user,
      name: "Articles id desc",
      path: "/admin/articles",
      query_string: "order=id_desc",
      resource_key: "articles"
    )

    visit admin_favorites_path

    expect(page).to have_content(I18n.t("active_admin.favorites.title"))
    expect(page).to have_content("Articles id desc")
    click_link "Articles id desc"

    expect(page).to have_current_path(%r{\A/admin/articles})
    expect(page).to have_css(%([data-testid="filter-favorite"]))
  end
end
