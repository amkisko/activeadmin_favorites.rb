# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Filter favorite quick create", type: :system do
  it "saves a private filter favorite from the star form fallback and lists it in the hub", :aggregate_failures do
    user = create(:user)
    sign_in(user)

    visit admin_articles_path(order: "id_desc")

    expect(page).to have_css(%([data-testid="filter-favorite"]))
    star = find(%([data-testid="filter-favorite"]))
    expect(star[:"data-controller"]).to eq("activeadmin-favorites--filter-favorite")
    star.click

    expect(page).to have_current_path(%r{\A/admin/favorites/new}, url: false)
    fill_in "Name", with: "Articles id desc"
    click_button I18n.t("active_admin.favorites.create", default: "Create Favorite")

    expect(page).to have_content("Articles id desc")

    bookmark = ActiveAdmin::Favorites::FiltersFavorite.order(:id).last
    expect(bookmark).to be_present
    expect(bookmark.user_id).to eq(user.id)
    expect(bookmark.path).to eq("/admin/articles")
    expect(bookmark.query_string).to eq("order=id_desc")
    expect(bookmark.published).to be(false)
  end
end
