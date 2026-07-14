# frozen_string_literal: true

module ActiveAdmin
  module Favorites
    module UserRecord
      extend ActiveSupport::Concern

      class_methods do
        def define_favorites_user_association!
          return if favorites_user_association_defined?

          config = ActiveAdmin::Favorites.config
          belongs_to config.user_association_name,
            class_name: config.user_class,
            foreign_key: config.user_foreign_key

          self.favorites_user_association_defined = true
        end
      end

      included do
        class_attribute :favorites_user_association_defined, instance_accessor: false, default: false
      end
    end
  end
end
