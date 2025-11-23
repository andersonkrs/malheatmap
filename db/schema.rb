# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2024_10_01_153156) do
  create_table "_litestream_lock", id: false, force: :cascade do |t|
    t.integer "id"
  end

  create_table "_litestream_seq", force: :cascade do |t|
    t.integer "seq"
  end

  create_table "access_tokens", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "discarded_at"
    t.string "refresh_token"
    t.datetime "refresh_token_expires_at"
    t.string "token"
    t.datetime "token_expires_at"
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.index ["user_id"], name: "index_access_tokens_on_user_id", unique: true, where: "(discarded_at IS NULL)"
  end

  create_table "active_storage_attachments", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.datetime "created_at", precision: nil, null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.string "content_type"
    t.datetime "created_at", precision: nil, null: false
    t.string "filename", null: false
    t.string "key", null: false
    t.text "metadata"
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "activities", force: :cascade do |t|
    t.integer "amount", null: false
    t.datetime "created_at", null: false
    t.date "date", null: false
    t.bigint "item_id", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["user_id", "item_id", "date"], name: "index_activities_on_user_id_and_item_id_and_date", unique: true
  end

  create_table "backups", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "failure_message"
    t.datetime "finished_at"
    t.string "key", null: false
    t.datetime "started_at"
    t.datetime "updated_at", null: false
    t.index ["key"], name: "index_backups_on_key", unique: true
  end

  create_table "blazer_audits", force: :cascade do |t|
    t.datetime "created_at"
    t.string "data_source"
    t.integer "query_id"
    t.text "statement"
    t.integer "user_id"
    t.index ["query_id"], name: "index_blazer_audits_on_query_id"
    t.index ["user_id"], name: "index_blazer_audits_on_user_id"
  end

  create_table "blazer_checks", force: :cascade do |t|
    t.string "check_type"
    t.datetime "created_at", null: false
    t.integer "creator_id"
    t.text "emails"
    t.datetime "last_run_at"
    t.text "message"
    t.integer "query_id"
    t.string "schedule"
    t.text "slack_channels"
    t.string "state"
    t.datetime "updated_at", null: false
    t.index ["creator_id"], name: "index_blazer_checks_on_creator_id"
    t.index ["query_id"], name: "index_blazer_checks_on_query_id"
  end

  create_table "blazer_dashboard_queries", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "dashboard_id"
    t.integer "position"
    t.integer "query_id"
    t.datetime "updated_at", null: false
    t.index ["dashboard_id"], name: "index_blazer_dashboard_queries_on_dashboard_id"
    t.index ["query_id"], name: "index_blazer_dashboard_queries_on_query_id"
  end

  create_table "blazer_dashboards", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "creator_id"
    t.string "name"
    t.datetime "updated_at", null: false
    t.index ["creator_id"], name: "index_blazer_dashboards_on_creator_id"
  end

  create_table "blazer_queries", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "creator_id"
    t.string "data_source"
    t.text "description"
    t.string "name"
    t.text "statement"
    t.string "status"
    t.datetime "updated_at", null: false
    t.index ["creator_id"], name: "index_blazer_queries_on_creator_id"
  end

  create_table "entries", force: :cascade do |t|
    t.integer "amount", null: false
    t.datetime "created_at", null: false
    t.bigint "item_id", null: false
    t.datetime "timestamp", precision: nil, null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["user_id", "timestamp", "item_id", "amount", "created_at"], name: "idx_on_user_id_timestamp_item_id_amount_created_at_2f13770dbb"
    t.index ["user_id", "timestamp"], name: "index_entries_on_user_id_and_date"
    t.check_constraint "amount > 0"
  end

  create_table "items", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "kind", null: false
    t.bigint "mal_id", null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.index ["mal_id", "kind"], name: "index_items_on_mal_id_and_kind", unique: true
    t.check_constraint "kind IN ('anime', 'manga')"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "anime_list_snapshot_updated_at"
    t.string "avatar_url"
    t.string "checksum"
    t.boolean "count_each_entry_as_an_activity", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "deactivated_at"
    t.float "latitude"
    t.string "location"
    t.float "longitude"
    t.bigint "mal_id"
    t.datetime "mal_synced_at"
    t.datetime "manga_list_snapshot_updated_at"
    t.datetime "profile_data_updated_at"
    t.string "time_zone", default: "UTC", null: false
    t.datetime "updated_at", null: false
    t.string "username", null: false, collation: "NOCASE"
    t.index ["mal_id"], name: "index_users_on_mal_id", unique: true
    t.index ["username"], name: "index_users_on_username", unique: true
  end

  add_foreign_key "access_tokens", "users"
  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "activities", "items"
  add_foreign_key "activities", "users"
  add_foreign_key "entries", "items"
  add_foreign_key "entries", "users"
end
