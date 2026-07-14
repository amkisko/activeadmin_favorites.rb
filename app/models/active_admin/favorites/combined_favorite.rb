# frozen_string_literal: true

module ActiveAdmin
  module Favorites
    class CombinedFavorite < Favorite
      validates :layout, presence: true
    end
  end
end
