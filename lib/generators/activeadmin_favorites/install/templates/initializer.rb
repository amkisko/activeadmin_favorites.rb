# frozen_string_literal: true

ActiveAdmin::Favorites.configure do |config|
  # Example for a custom staff model:
  # config.user_class = "AdminUser"
  # config.user_foreign_key = :admin_user_id
  # config.user_association_name = :admin_user
  # config.user_label_method = :email
  # config.current_user_method = :current_admin_user

  config.user_class = "User"
  config.user_foreign_key = :user_id
  config.user_association_name = :user
  config.user_label_method = :email
  config.current_user_method = :current_user
end
