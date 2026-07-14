# frozen_string_literal: true

module ActiveAdmin
  module Favorites
    class Favorite
      module QueryParams
        module_function

        def parse(query_string)
          return {} if query_string.blank?

          Rack::Utils.parse_nested_query(query_string.to_s).except("commit")
        end

        def build(params)
          Rack::Utils.build_nested_query(params.compact_blank).presence
        end

        def merge_query_string(query_string, q_overrides:)
          params = parse(query_string)
          params["q"] = (params["q"] || {}).merge(q_overrides.stringify_keys)
          build(params)
        end

        def without_q_keys(query_string, keys:)
          params = parse(query_string)
          query_filters = params["q"]
          return query_string if query_filters.blank?

          keys.each { |key| query_filters.delete(key.to_s) }
          params["q"] = query_filters.presence
          build(params)
        end

        def q_keys_for_macros(macros)
          Favorite::MacroResolver.q_keys(macros)
        end
      end
    end
  end
end
