# frozen_string_literal: true

module ActiveAdmin
  module Favorites
    class LensFavorite < Favorite
      validates :layout, presence: true
    end
  end
end
