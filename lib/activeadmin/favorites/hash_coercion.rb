# frozen_string_literal: true

module ActiveAdmin
  module Favorites
    module HashCoercion
      module_function

      def deep_stringify(value, default: {})
        case value
        when Hash
          value.deep_stringify_keys
        when ActionController::Parameters
          value.to_unsafe_h.deep_stringify_keys
        else
          return default unless value.respond_to?(:to_h)

          hash = value.to_h
          hash.is_a?(Hash) ? hash.deep_stringify_keys : default
        end
      end

      def assignment_values(assignments)
        case assignments
        when ActionController::Parameters
          assignments.to_unsafe_h.values
        when Hash
          assignments.values
        else
          Array(assignments)
        end
      end
    end
  end
end
