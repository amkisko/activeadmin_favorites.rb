# frozen_string_literal: true

module ActiveAdmin
  module Favorites
    module RegisterFavorites
      module_function

      def call
        return if resource_registered?

        ActiveAdmin.register Favorite, as: "favorites" do
          menu label: proc { I18n.t("active_admin.favorites.menu") }, priority: 2

          actions :index, :new, :create, :edit, :update, :destroy

          config.filters = false
          config.sort_order = "created_at_desc"

          permit_params :name, :note, :path, :query_string, :resource_key, :published, :macros_json,
            :use_advanced_macros, :kind, :type, :action, :include_layout, layout: {}

          controller do
            helper_method :current_favorites_user, :favorites_kind_tab_active?

            def current_favorites_user
              send(ActiveAdmin::Favorites.config.current_user_method)
            end

            def build_new_resource
              kind = params[:kind].presence || "filters"
              resource = Favorite.sti_class_for_kind(kind).new
              assign_new_favorite_defaults(resource)
              resource
            end

            def build_resource
              get_resource_ivar || begin
                kind = params.dig(:favorite, :kind).presence || params[:kind].presence || "filters"
                record = Favorite.sti_class_for_kind(kind).new
                record = assign_attributes(record, resource_params)
                authorize_resource!(record)
                set_resource_ivar(record)
              end
            end

            def create
              build_resource
              assign_favorite_owner(resource)
              apply_macros_from_params(resource) if macro_form_submitted?
              apply_layout_from_params(resource)

              if resource.errors.any? || !resource.save
                render :new, status: :unprocessable_entity
              else
                redirect_to admin_favorites_path(kind: resource.kind), notice: create_notice_for(resource)
              end
            end

            def update
              resource.assign_attributes(
                permitted_params[:favorite].except(
                  :macros_json, :use_advanced_macros, :include_layout, :layout, :kind,
                  :path, :query_string, :resource_key, :action
                )
              )
              apply_macros_from_params(resource) if macro_form_submitted?
              apply_layout_from_params(resource)

              if resource.errors.any? || !resource.save
                render :edit, status: :unprocessable_entity
              else
                redirect_to admin_favorites_path(kind: resource.kind), notice: I18n.t("active_admin.favorites.updated")
              end
            end

            def scoped_collection
              association = ActiveAdmin::Favorites.config.user_association_name
              scope = super.includes(association)
              kind = params[:kind].presence
              return scope if kind.blank?
              return scope unless Favorite::KINDS.include?(kind)

              scope.merge(Favorite.sti_class_for_kind(kind).all)
            end

            private

            def assign_new_favorite_defaults(resource)
              if params[:path].present?
                resource.path = params[:path]
                resource.query_string = Favorite.sanitize_query_string(params[:query_string])
                resource.resource_key = params[:resource_key]
              end
              resource.action = params[:action_name] if params[:action_name].present?
              resource.action ||= "index"
              resource.kind = params[:kind] if params[:kind].present?

              if resource.layout.blank? && resource.resource_key.present?
                default = ViewLensDefault.for_user(
                  current_favorites_user,
                  resource_key: resource.resource_key,
                  action: resource.action
                )
                resource.layout = default.layout if default
              end

              if resource.name.blank? && resource.resource_key.present?
                resource.name = Favorite.suggested_name(
                  resource_key: resource.resource_key,
                  query_string: resource.query_string,
                  kind: resource.kind
                )
              end

              if ActiveModel::Type::Boolean.new.cast(params[:include_layout])
                resource.layout = layout_from_params || resource.layout
                if resource.kind == "filters" && resource.query_string.present? && resource.layout.present?
                  resource = resource.promote_to_kind!("combined")
                end
              end
            end

            def assign_favorite_owner(resource)
              resource.public_send(:"#{ActiveAdmin::Favorites.config.user_foreign_key}=", current_favorites_user.id)
            end

            def apply_macros_from_params(favorite)
              favorite.use_advanced_macros = params.dig(:favorite, :use_advanced_macros)
              favorite.macros_json = params.dig(:favorite, :macros_json)
              favorite.assign_macros_from_form!(
                template_assignments: params[:macro_template_assignments],
                macros_json: favorite.macros_json,
                use_advanced_macros: favorite.use_advanced_macros
              )
            end

            def apply_layout_from_params(favorite)
              return favorite unless ActiveModel::Type::Boolean.new.cast(params.dig(:favorite, :include_layout))

              favorite.layout = layout_from_params || favorite.layout
              if favorite.kind == "filters" && favorite.query_string.present? && favorite.layout.present?
                favorite = favorite.promote_to_kind!("combined")
                set_resource_ivar(favorite)
              end
              favorite
            end

            def layout_from_params
              raw_layout = params.dig(:favorite, :layout)
              return if raw_layout.blank?

              parsed =
                if raw_layout.is_a?(String)
                  JSON.parse(raw_layout)
                else
                  raw_layout
                end
              ViewLens::Layout.normalize(parsed)
            rescue JSON::ParserError
              nil
            end

            def macro_form_submitted?
              params[:macro_form_submitted].present?
            end

            def favorites_kind_tab_active?(kind)
              if kind.nil?
                params[:kind].blank?
              else
                params[:kind] == kind
              end
            end

            def create_notice_for(resource)
              case resource.kind
              when "lens"
                I18n.t("active_admin.favorites.lens_created")
              when "combined"
                I18n.t("active_admin.favorites.combined_created")
              else
                I18n.t("active_admin.favorites.created")
              end
            end
          end

          index title: proc { I18n.t("active_admin.favorites.title") } do
            nav class: "flex flex-wrap gap-3 mb-4", "aria-label": I18n.t("active_admin.favorites.kind_navigation") do
              link_to I18n.t("active_admin.favorites.kinds.all"),
                admin_favorites_path,
                class: favorites_kind_tab_active?(nil) ? "font-semibold underline" : "text-gray-600 dark:text-gray-300"
              Favorite::KINDS.each do |kind|
                link_to I18n.t("active_admin.favorites.kinds.#{kind}"),
                  admin_favorites_path(kind: kind),
                  class: favorites_kind_tab_active?(kind) ? "font-semibold underline" : "text-gray-600 dark:text-gray-300"
              end
            end

            column :name do |favorite|
              link_to favorite.name, favorite.open_url, class: "no-underline font-medium"
            end
            column I18n.t("active_admin.favorites.kind_column"), &:kind_label
            column :resource, &:resource_label
            column I18n.t("active_admin.favorites.filters_column") do |favorite|
              (favorite.kind == "lens") ? "—" : favorite.filter_summary
            end
            column I18n.t("active_admin.favorites.visibility_column") do |favorite|
              if favorite.published?
                I18n.t("active_admin.favorites.visibility.published", time: l(favorite.published_at, default: "—"))
              else
                I18n.t("active_admin.favorites.visibility.mine")
              end
            end
            column I18n.t("active_admin.favorites.creator_column") do |favorite|
              next "—" if favorite.owned_by?(current_favorites_user)

              owner = favorite.public_send(ActiveAdmin::Favorites.config.user_association_name)
              label_method = ActiveAdmin::Favorites.config.user_label_method
              owner&.public_send(label_method) || "—"
            end
            actions defaults: false do |favorite|
              item I18n.t("active_admin.favorites.open"), favorite.open_url, class: "member_link"
              if authorized?(:update, favorite)
                item I18n.t("active_admin.edit"), edit_admin_favorite_path(favorite), class: "member_link"
                item I18n.t("active_admin.delete"), admin_favorite_path(favorite),
                  class: "member_link",
                  method: :delete,
                  data: {confirm: I18n.t("active_admin.delete_confirmation")}
              end
            end
          end

          form do |f|
            f.semantic_errors(*f.object.errors.attribute_names)
            f.inputs I18n.t("active_admin.favorites.form_panel") do
              f.input :name, input_html: {autofocus: true}
              f.input :note, as: :text, input_html: {rows: 3}
              f.input :published, as: :boolean,
                label: I18n.t("active_admin.favorites.published")
              if f.object.new_record?
                f.input :path, as: :hidden
                f.input :query_string, as: :hidden
                f.input :resource_key, as: :hidden
                f.input :kind, as: :hidden
                f.input :action, as: :hidden
              end
              if f.object.new_record? && f.object.kind == "filters"
                f.input :include_layout, as: :boolean,
                  label: I18n.t("active_admin.favorites.include_layout")
                f.input :layout, as: :hidden,
                  input_html: {value: (f.object.layout || {}).to_json}
              end
            end

            if f.object.kind != "lens"
              render partial: "active_admin/favorites/macro_fields", locals: {f: f}
            end

            f.actions
          end

          config.remove_action_item :new
        end
      end

      def resource_registered?
        ActiveAdmin.application.namespace(ActiveAdmin::Favorites.config.namespace_name)
          .resources.any? { |resource| resource.resource_class == Favorite }
      end
    end
  end
end
