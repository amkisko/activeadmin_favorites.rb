# frozen_string_literal: true

module ActiveAdmin
  module Favorites
    class Favorite < ApplicationRecord
      include UserRecord

      KINDS = %w[filters lens combined].freeze
      ACTIONS = %w[index show].freeze

      STI_TYPE_BY_KIND = {
        "filters" => "ActiveAdmin::Favorites::FiltersFavorite",
        "lens" => "ActiveAdmin::Favorites::LensFavorite",
        "combined" => "ActiveAdmin::Favorites::CombinedFavorite"
      }.freeze

      KIND_BY_STI_TYPE = STI_TYPE_BY_KIND.invert.freeze

      attribute :macros, :json, default: -> { [] }
      attribute :layout, :json

      attr_accessor :macros_json, :use_advanced_macros, :include_layout

      validates :name, :resource_key, :path, presence: true
      validates :published, inclusion: {in: [true, false]}
      validates :macros_version, numericality: {only_integer: true, greater_than: 0}
      validates :action, inclusion: {in: ACTIONS}, allow_nil: true

      validate :path_starts_with_namespace_prefix
      validate :unique_path_query_and_type_per_user
      validate :validate_macros_schema

      before_validation :normalize_blank_query_string

      before_save :sync_published_at
      before_validation :assign_default_type

      scope :visible_to, ->(user) {
        foreign_key = ActiveAdmin::Favorites.config.user_foreign_key
        where(foreign_key => user).or(where(published: true))
      }

      scope :filters_kind, -> { where(type: FiltersFavorite.name) }
      scope :lens_kind, -> { where(type: LensFavorite.name) }
      scope :combined_kind, -> { where(type: CombinedFavorite.name) }

      def self.table_name
        ActiveAdmin::Favorites.config.table_name
      end

      def self.model_name
        @model_name ||= ActiveModel::Name.new(self, nil, "Favorite")
      end

      def self.policy_class
        ActiveAdmin::Favorites::FavoritePolicy
      end

      def self.sti_class_for_kind(kind)
        STI_TYPE_BY_KIND.fetch(kind.to_s).constantize
      end

      def self.kind_for_type(type_name)
        KIND_BY_STI_TYPE.fetch(type_name)
      end

      def self.sanitize_query_string(raw_query_string)
        return if raw_query_string.blank?

        QueryParams.build(QueryParams.parse(raw_query_string))
      end

      def self.suggested_name(resource_key:, query_string:, kind: "filters")
        label = resource_label_for(resource_key)
        summary =
          case kind
          when "lens"
            I18n.t("active_admin.favorites.lens_summary", default: "Page layout")
          when "combined"
            [filter_summary_for(query_string, macros: []), I18n.t("active_admin.favorites.lens_summary", default: "Page layout")].compact.join(" · ")
          else
            filter_summary_for(query_string, macros: [])
          end
        [label, summary].compact.join(" — ").truncate(120)
      end

      def self.resource_label_for(resource_key)
        return resource_key.humanize if resource_key.blank?

        config = active_admin_resource_for(resource_key)
        config&.resource_label || resource_key.tr("_", " ").titleize
      end

      def self.filter_summary_for(query_string, macros: [])
        params = QueryParams.parse(query_string)
        parts = []
        parts << "scope: #{params["scope"]}" if params["scope"].present?

        macro_parts = Array(macros).map { |macro| MacroCatalog.describe(macro) }
        parts.concat(macro_parts)

        query_filters = params["q"]
        if query_filters.is_a?(Hash) && query_filters.any?
          parts << query_filters.keys.map { |key| key.sub(/_(eq|gteq|lteq|cont)\z/, "").tr("_", " ") }.join(", ")
        end

        parts << "sort: #{params["order"]}" if params["order"].present?
        parts.join(" · ").presence
      end

      def self.ransackable_attributes_for(resource_key)
        resource_class = resource_class_for(resource_key)
        return [] unless resource_class

        if resource_class.respond_to?(:ransackable_attributes)
          resource_class.ransackable_attributes
        else
          []
        end
      end

      def self.resource_class_for(resource_key)
        active_admin_resource_for(resource_key)&.resource_class
      end

      def self.active_admin_resource_for(resource_key)
        namespace = ActiveAdmin.application.namespace(ActiveAdmin::Favorites.config.namespace_name)
        namespace.resources.find do |resource|
          resource.is_a?(ActiveAdmin::Resource) && resource.resource_name.route_key == resource_key
        end
      end

      def self.detected_ranges(query_string:, resource_key:)
        RangeDetector.call(query_string:, resource_key:)
      end

      def self.macro_assignments_from_macros(macros)
        Array(macros).filter_map do |macro|
          next unless macro["type"] == "template"

          {
            "enabled" => "1",
            "attribute" => macro["attribute"],
            "name" => macro["name"]
          }
        end
      end

      def kind
        self.class.kind_for_type(type)
      end

      def kind=(value)
        self.type = self.class.sti_class_for_kind(value).name
      end

      def promote_to_kind!(value)
        sti_class = self.class.sti_class_for_kind(value)
        return self if is_a?(sti_class)

        promoted = becomes(sti_class)
        promoted.type = sti_class.name
        promoted
      end

      def filter_summary
        self.class.filter_summary_for(query_string, macros: macros)
      end

      def resource_label
        self.class.resource_label_for(resource_key)
      end

      def layout_object
        ViewLens::Layout.new(layout || {})
      end

      def resolved_query_string(at: Time.zone.now)
        return query_string if macros.blank?

        q_overrides = MacroResolver.call(macros: macros, at: at)
        QueryParams.merge_query_string(query_string, q_overrides: q_overrides)
      end

      def index_url(at: Time.zone.now, favorite_id: nil)
        resolved = resolved_query_string(at: at)
        url = resolved.present? ? "#{path}?#{resolved}" : path
        if favorite_id.present?
          separator = url.include?("?") ? "&" : "?"
          url = "#{url}#{separator}favorite_id=#{favorite_id}"
        elsif id.present? && layout.present?
          separator = url.include?("?") ? "&" : "?"
          url = "#{url}#{separator}favorite_id=#{id}"
        end
        url
      end

      def show_url(favorite_id: nil)
        return path if path.blank?

        if favorite_id.present? || (id.present? && layout.present?)
          favorite_param = favorite_id || id
          "#{path}?favorite_id=#{favorite_param}"
        else
          path
        end
      end

      def open_url(at: Time.zone.now)
        if is_a?(LensFavorite)
          (action == "show") ? show_url : index_url(at: at)
        else
          index_url(at: at)
        end
      end

      def detected_ranges
        self.class.detected_ranges(query_string:, resource_key: resource_key)
      end

      def macro_form_rows
        rows_by_attribute = {}

        detected_ranges.each do |range|
          rows_by_attribute[range[:attribute]] = {
            attribute: range[:attribute],
            gteq: range[:gteq],
            lteq: range[:lteq],
            enabled: false,
            name: "previous_calendar_month"
          }
        end

        Array(macros).each do |macro|
          next unless macro["type"] == "template"

          attribute = macro["attribute"]
          rows_by_attribute[attribute] ||= {attribute: attribute}
          rows_by_attribute[attribute][:enabled] = true
          rows_by_attribute[attribute][:name] = macro["name"]
        end

        rows_by_attribute.values
      end

      def macros_json_for_form
        macros_json.presence || JSON.pretty_generate(macros)
      end

      def owned_by?(user)
        public_send(:"#{ActiveAdmin::Favorites.config.user_foreign_key}") == user.id
      end

      def assign_macros_from_form!(template_assignments:, macros_json:, use_advanced_macros:)
        parsed_macros =
          if ActiveModel::Type::Boolean.new.cast(use_advanced_macros) && macros_json.present?
            MacroBuilder.from_json(macros_json)
          else
            MacroBuilder.from_template_assignments(template_assignments)
          end

        self.macros = parsed_macros
        MacroValidator.validate!(macros, resource_key: resource_key)
        strip_query_string_for_macros!
        true
      rescue JSON::ParserError
        errors.add(:macros_json, I18n.t("active_admin.favorites.macros_json_invalid"))
        false
      rescue MacroValidator::ValidationError => error
        errors.add(:macros, error.message)
        false
      end

      def kind_label
        I18n.t("active_admin.favorites.kinds.#{kind}", default: kind.humanize)
      end

      private

      def assign_default_type
        self.type = FiltersFavorite.name if type.blank?
      end

      def path_starts_with_namespace_prefix
        return if path.blank?

        prefix = ActiveAdmin::Favorites.config.namespace_path_prefix
        return if path.start_with?(prefix)

        errors.add(:path, I18n.t("active_admin.favorites.errors.path_namespace", default: "must stay within the configured admin area"))
      end

      def normalize_blank_query_string
        self.query_string = "" if query_string.nil?
      end

      def unique_path_query_and_type_per_user
        foreign_key = ActiveAdmin::Favorites.config.user_foreign_key
        owner_id = public_send(foreign_key)
        return if owner_id.blank? || path.blank?

        scope = self.class.where(
          path: path,
          query_string: query_string_for_uniqueness,
          type: type
        )
        scope = scope.where(foreign_key => owner_id)
        scope = scope.where.not(id: id) if persisted?

        return unless scope.exists?

        errors.add(:base, I18n.t("active_admin.favorites.errors.duplicate_favorite", default: "already saved for this page and filters"))
      end

      def query_string_for_uniqueness
        query_string.presence || ""
      end

      def strip_query_string_for_macros!
        keys = QueryParams.q_keys_for_macros(macros)
        self.query_string = QueryParams.without_q_keys(query_string, keys: keys)
      end

      def validate_macros_schema
        MacroValidator.validate!(macros, resource_key: resource_key)
      rescue MacroValidator::ValidationError => error
        errors.add(:macros, error.message)
      end

      def sync_published_at
        if published?
          self.published_at = Time.current if published_at.nil? || will_save_change_to_published?
        else
          self.published_at = nil
        end
      end
    end
  end
end
