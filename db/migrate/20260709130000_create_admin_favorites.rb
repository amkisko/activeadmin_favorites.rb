# frozen_string_literal: true

class CreateAdminFavorites < ActiveRecord::Migration[7.2]
  include ActiveAdmin::Favorites::MigrationSupport

  def change
    json_type = favorites_json_column_type
    user_foreign_key = favorites_user_foreign_key

    create_table :admin_favorites do |t|
      t.string :type, null: false
      t.bigint user_foreign_key, null: false
      t.string :name, null: false
      t.text :note
      t.string :resource_key, null: false
      t.string :path, null: false
      t.text :query_string
      t.boolean :published, null: false, default: false
      t.datetime :published_at
      t.public_send(json_type, :macros, null: false, default: [])
      t.integer :macros_version, null: false, default: 1
      t.string :action
      t.public_send(json_type, :layout)

      t.timestamps
    end

    add_index :admin_favorites, [user_foreign_key, :path, :query_string, :type],
      unique: true,
      name: "index_admin_favorites_on_user_path_query_and_type"
    add_index :admin_favorites, :type
  end
end
