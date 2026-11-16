# frozen_string_literal: true

require "rails_helper"

RSpec.describe ActiveAdmin::Favorites::RegisterFavorites do
  def favorite_resource
    namespace = ActiveAdmin.application.namespace(ActiveAdmin::Favorites.config.namespace_name)
    namespace.resources.find do |resource|
      resource.is_a?(ActiveAdmin::Resource) && resource.resource_class == ActiveAdmin::Favorites::Favorite
    end
  end

  def reload_active_admin!
    ActiveAdmin.application.unload!
    ActiveAdmin.application.load!
    ActiveAdmin::GraphQL.clear_schema_cache! if defined?(ActiveAdmin::GraphQL)
    Rails.application.reload_routes!
  end

  around do |example|
    original = ActiveAdmin::Favorites.config.graphql
    example.run
  ensure
    ActiveAdmin::Favorites.configure { |configuration| configuration.graphql = original }
    reload_active_admin!
  end

  it "defaults GraphQL registration to enabled" do
    expect(ActiveAdmin::Favorites::Configuration.new.graphql).to be(true)
  end

  it "registers an enabled GraphQL surface by default when GraphQL is loaded" do
    reload_active_admin!

    expect(favorite_resource.graphql_config).not_to be_disabled
    expect(favorite_resource.graphql_config.resolve_create_proc).to be_present
  end

  it "disables the GraphQL surface when config.graphql is false" do
    ActiveAdmin::Favorites.configure { |configuration| configuration.graphql = false }
    reload_active_admin!

    expect(favorite_resource.graphql_config).to be_disabled
    expect(favorite_resource.graphql_config.resolve_create_proc).to be_nil
  end
end
