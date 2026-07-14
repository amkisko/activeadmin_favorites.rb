# frozen_string_literal: true

class User < ApplicationRecord
  has_many :favorites,
    class_name: "ActiveAdmin::Favorites::Favorite",
    foreign_key: ActiveAdmin::Favorites.config.user_foreign_key,
    inverse_of: :user,
    dependent: :destroy
end
