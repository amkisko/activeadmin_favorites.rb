# frozen_string_literal: true

module ActiveAdmin
  module Favorites
    class ViewLensDefault < ApplicationRecord
      include UserRecord

      self.table_name = "active_admin_view_lens_defaults"

      attribute :layout, :json, default: -> { ViewLens::Layout.empty.layout }

      validates :resource_key, :action, presence: true
      validates :action, inclusion: {in: %w[index show]}
      validates :resource_key, uniqueness: {scope: [ActiveAdmin::Favorites.config.user_foreign_key, :action]}

      def self.for_user(user, resource_key:, action:)
        find_by(user_foreign_key_column => user.id, :resource_key => resource_key, :action => action)
      end

      def self.user_foreign_key_column
        ActiveAdmin::Favorites.config.user_foreign_key
      end

      def self.upsert_for!(user:, resource_key:, action:, layout:)
        record = find_or_initialize_by(
          user_foreign_key_column => user.id,
          :resource_key => resource_key,
          :action => action
        )
        record.layout = ViewLens::Layout.normalize(layout)
        record.save!
        record
      end

      def layout_object
        ViewLens::Layout.new(layout)
      end
    end
  end
end
