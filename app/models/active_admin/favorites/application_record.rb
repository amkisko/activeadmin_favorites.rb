# frozen_string_literal: true

module ActiveAdmin
  module Favorites
    class ApplicationRecord < ::ApplicationRecord
      self.abstract_class = true
    end
  end
end
