# frozen_string_literal: true

module ActiveAdmin
  module Favorites
    class FavoritePolicy < ApplicationPolicy
      def index?
        staff?
      end

      def show?
        visible?
      end

      def create?
        staff?
      end

      def new?
        create?
      end

      def update?
        owner?
      end

      def edit?
        update?
      end

      def destroy?
        owner?
      end

      default_scope do |relation|
        return relation.none unless staff?

        relation.visible_to(user)
      end

      private

      def staff?
        user.present?
      end

      def visible?
        staff? && (owner? || record.published?)
      end

      def owner?
        foreign_key = ActiveAdmin::Favorites.config.user_foreign_key
        staff? && record.public_send(foreign_key) == user.id
      end
    end
  end
end
