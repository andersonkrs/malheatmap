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

ActiveRecord::Schema[7.2].define(version: 2024_01_03_020927) do
  create_table "access_tokens", force: :cascade do |t|
    t.string "token"
    t.string "refresh_token"
    t.datetime "token_expires_at"
    t.datetime "refresh_token_expires_at"
    t.datetime "discarded_at"
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_access_tokens_on_user_id", unique: true, where: "(discarded_at IS NULL)"
  end

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", precision: nil, null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", precision: nil, null: false
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "activities", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "item_id", null: false
    t.date "date", null: false
    t.integer "amount", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id", "item_id", "date"], name: "index_activities_on_user_id_and_item_id_and_date", unique: true
  end

  create_table "entries", force: :cascade do |t|
    t.datetime "timestamp", precision: nil, null: false
    t.integer "amount", null: false
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "item_id", null: false
    t.index ["user_id", "item_id", "timestamp"], name: "index_entries_on_user_id_and_item_id_and_date"
    t.check_constraint "amount > 0"
  end

  create_table "items", force: :cascade do |t|
    t.bigint "mal_id", null: false
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "kind", null: false
    t.index ["mal_id", "kind"], name: "index_items_on_mal_id_and_kind", unique: true
    t.check_constraint "kind IN ('anime', 'manga')"
  end

  create_table "users", force: :cascade do |t|
    t.string "username", null: false, collation: "NOCASE"
    t.string "avatar_url"
    t.string "checksum"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "location"
    t.string "time_zone", default: "UTC", null: false
    t.float "latitude"
    t.float "longitude"
    t.boolean "count_each_entry_as_an_activity", default: false, null: false
    t.bigint "mal_id"
    t.datetime "profile_data_updated_at"
    t.datetime "anime_list_snapshot_updated_at"
    t.datetime "manga_list_snapshot_updated_at"
    t.datetime "deactivated_at"
    t.datetime "mal_synced_at"
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
