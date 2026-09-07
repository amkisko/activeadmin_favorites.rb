# frozen_string_literal: true

ActiveAdmin.register Article, as: "IndexOnlyArticle" do
  menu false
  actions :index

  collection_action :download, method: :get do
    respond_to do |format|
      format.json { render json: [] }
      format.csv { send_data "id\n", filename: "index_only_articles.csv" }
    end
  end
end
