# frozen_string_literal: true

module ActiveAdmin
  module Favorites
    # Place this engine's views ahead of ActiveAdmin's so resource index/show
    # overrides (catalog injection) win, while the host app/views path stays first.
    module ViewPaths
      module_function

      def prefer_over_active_admin!(view_paths)
        path_strings = view_paths.to_a.map { |path| path.to_s }
        reordered = reorder_path_strings(path_strings)
        return view_paths if reordered.equal?(path_strings)

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
        return path_strings unless path_strings.include?(favorites_root)

        active_admin_root = path_strings.find do |path|
          path.match?(%r{/gems/activeadmin-[^/]+/app/views\z})
        end
        return path_strings unless active_admin_root

        favorites_index = path_strings.index(favorites_root)
        active_admin_index = path_strings.index(active_admin_root)
        return path_strings if favorites_index < active_admin_index

        moved = path_strings.dup
        moved.delete_at(favorites_index)
        moved.insert(moved.index(active_admin_root), favorites_root)
        moved
      end
      module_function :reorder_path_strings
      private_class_method :reorder_path_strings
    end
  end
end
