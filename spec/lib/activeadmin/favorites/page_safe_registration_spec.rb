# frozen_string_literal: true

require "rails_helper"

RSpec.describe ActiveAdmin::Favorites do
  def favorite_resource
    namespace = ActiveAdmin.application.namespace(ActiveAdmin::Favorites.config.namespace_name)
    namespace.resources.find do |resource|
      resource.is_a?(ActiveAdmin::Resource) && resource.resource_class == ActiveAdmin::Favorites::Favorite
    end
  end

  around do |example|
    ActiveAdmin.application.unload!
    ActiveAdmin.register_page "Dashboard" do
      content {}
    end
    example.run
  ensure
    ActiveAdmin.application.unload!
    ActiveAdmin.application.load!
    Rails.application.reload_routes!
  end

  it "registers and installs favorites when a page is already loaded" do
    ActiveAdmin::Favorites.register_resources!
    ActiveAdmin::Favorites.install!

    expect(favorite_resource).to be_present
  end
end
