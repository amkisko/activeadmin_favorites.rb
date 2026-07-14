# frozen_string_literal: true

ActiveRecord::Schema.define(version: 20_260_709_130_000) do
  create_table :users, force: :cascade do |t|
    t.string :email
    t.timestamps
  end

  create_table :articles, force: :cascade do |t|
    t.string :title
    t.string :status
    t.timestamps
  end

  create_table :admin_favorites, force: :cascade do |t|
    t.string :type, null: false
    t.bigint :user_id, null: false
    t.string :name, null: false
    t.text :note
    t.string :resource_key, null: false
    t.string :path, null: false
    t.text :query_string
    t.boolean :published, default: false, null: false
    t.datetime :published_at
    t.json :macros, default: [], null: false
    t.integer :macros_version, default: 1, null: false
    t.string :action
    t.json :layout
    t.datetime :created_at, null: false
    t.datetime :updated_at, null: false
    t.index [:user_id, :path, :query_string, :type], unique: true, name: "index_admin_favorites_on_user_path_query_and_type"
    t.index :type
  end

  create_table :active_admin_view_lens_defaults, force: :cascade do |t|
    t.bigint :user_id, null: false
    t.string :resource_key, null: false
    t.string :action, null: false
    t.json :layout, default: {}, null: false
    t.datetime :created_at, null: false
    t.datetime :updated_at, null: false
    t.index [:user_id, :resource_key, :action], unique: true, name: "index_view_lens_defaults_on_user_resource_action"
  end
end
