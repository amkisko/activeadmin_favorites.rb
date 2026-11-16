# frozen_string_literal: true

ActiveAdmin.setup do |config|
  config.authentication_method = false
  config.current_user_method = :current_user
  config.site_title = "Dummy"
  config.logout_link_path = false
  config.comments = false

  config.namespace :admin do |admin|
    admin.graphql = true
  end
end
