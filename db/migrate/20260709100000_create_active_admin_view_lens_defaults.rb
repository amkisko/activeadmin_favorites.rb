# frozen_string_literal: true

class CreateActiveAdminViewLensDefaults < ActiveRecord::Migration[7.2]
  include ActiveAdmin::Favorites::MigrationSupport

  def change
    json_type = favorites_json_column_type
    user_foreign_key = favorites_user_foreign_key

    create_table :active_admin_view_lens_defaults do |t|
      t.bigint user_foreign_key, null: false
      t.string :resource_key, null: false
      t.string :action, null: false
      t.public_send(json_type, :layout, null: false, default: {})

      t.timestamps
    end

    add_index :active_admin_view_lens_defaults,
      [user_foreign_key, :resource_key, :action],
      unique: true,
      name: "index_view_lens_defaults_on_user_resource_action"
  end
end
