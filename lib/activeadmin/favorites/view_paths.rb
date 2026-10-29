# frozen_string_literal: true

module ActiveAdmin
  module Favorites
    # Place this engine's views immediately before ActiveAdmin's so resource
    # index/show overrides (catalog injection) win. Rails engines prepend their
    # view paths, so favorites can otherwise sit ahead of the host app/views and
    # shadow customized templates such as active_admin/_html_head.
    module ViewPaths
      module_function

      def prefer_over_active_admin!(view_paths)
        path_strings = view_paths.to_a.map { |path| path.to_s }
        reordered = reorder_path_strings(path_strings)
        return view_paths if reordered == path_strings

        ActionView::PathSet.new(reordered)
      end

      def install!
        return unless defined?(ActionController::Base)

        ActionController::Base.view_paths = prefer_over_active_admin!(
          ActionController::Base.view_paths
        )
      end

      def reorder_path_strings(path_strings)
        favorites_root = Engine.root.join("app/views").to_s
        active_admin_root = active_admin_views_root(path_strings)
        return path_strings unless path_strings.include?(favorites_root) && active_admin_root
        return path_strings if already_before_active_admin?(path_strings, favorites_root, active_admin_root)

        place_before_active_admin(path_strings, favorites_root, active_admin_root)
      end

      def active_admin_views_root(path_strings)
        path_strings.find { |path| path.match?(%r{/gems/activeadmin-[^/]+/app/views\z}) }
      end

      def already_before_active_admin?(path_strings, favorites_root, active_admin_root)
        path_strings.index(favorites_root) == path_strings.index(active_admin_root) - 1
      end

      def place_before_active_admin(path_strings, favorites_root, active_admin_root)
        moved = path_strings.dup
        moved.delete(favorites_root)
        moved.insert(moved.index(active_admin_root), favorites_root)
        moved
      end

      module_function :reorder_path_strings, :active_admin_views_root,
        :already_before_active_admin?, :place_before_active_admin
      private_class_method :reorder_path_strings, :active_admin_views_root,
        :already_before_active_admin?, :place_before_active_admin
    end
  end
end
