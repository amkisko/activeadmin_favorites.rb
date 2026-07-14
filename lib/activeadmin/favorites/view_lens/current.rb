# frozen_string_literal: true

module ActiveAdmin
  module Favorites
    module ViewLens
      class Current < ActiveSupport::CurrentAttributes
        attribute :layout, :catalog, :catalog_context
        attribute :registered_columns, :registered_panels, :registered_rows, :block_column_sequence

        def registered_columns
          super || self.registered_columns = Hash.new { |hash, key| hash[key] = [] }
        end

        def registered_panels
          super || self.registered_panels = Hash.new { |hash, key| hash[key] = [] }
        end

        def registered_rows
          super || self.registered_rows = Hash.new { |hash, key| hash[key] = [] }
        end

        def block_column_sequence
          super || self.block_column_sequence = Hash.new(0)
        end
      end
    end
  end
end
