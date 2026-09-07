# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Index-only ActiveAdmin resource formats", type: :request do
  around do |example|
    previous = ActionController::Base.raise_on_missing_callback_actions
    ActionController::Base.raise_on_missing_callback_actions = true
    example.run
  ensure
    ActionController::Base.raise_on_missing_callback_actions = previous
  end

  it "keeps the HTML index working" do
    get admin_index_only_articles_path

    expect(response).to have_http_status(:ok)
  end

  it "returns JSON from a collection action" do
    get download_admin_index_only_articles_path(format: :json)

    expect(response).to have_http_status(:ok)
  end

  it "returns CSV from a collection action" do
    get download_admin_index_only_articles_path(format: :csv)

    expect(response).to have_http_status(:ok)
  end
end
