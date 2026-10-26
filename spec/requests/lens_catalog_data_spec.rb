# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Lens catalog data embedding", type: :request do
  it "embeds catalog JSON that JSON.parse can read from the script body", :aggregate_failures do
    get admin_articles_path

    expect(response).to have_http_status(:ok)

    match = response.body.match(
      %r{id="favorites-lens-catalog-articles-index"[^>]*>(.*?)</script>}m
    )
    expect(match).to be_present

    script_body = match[1]
    expect(script_body).not_to include("&quot;")

    catalog = JSON.parse(script_body)
    expect(catalog).to be_an(Array)
    expect(catalog).not_to be_empty
    expect(catalog.first).to include("id", "label", "group")
  end
end
