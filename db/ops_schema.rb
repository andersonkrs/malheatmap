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

ActiveRecord::Schema[8.1].define(version: 2024_07_13_161619) do
  create_table "crawling_log_entries", force: :cascade do |t|
    t.string "checksum"
    t.datetime "created_at", null: false
    t.binary "data"
    t.boolean "failure", default: false, null: false
    t.string "failure_message"
    t.datetime "purge_after", null: false
    t.string "purge_method"
    t.json "raw_data"
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.index ["purge_after"], name: "index_crawling_log_entries_on_purging"
    t.index ["user_id"], name: "index_crawling_log_entries_on_user_id"
  end

  create_table "crawling_log_entry_visited_pages", force: :cascade do |t|
    t.text "body"
    t.integer "crawling_log_entry_id"
    t.string "url"
    t.index ["crawling_log_entry_id"], name: "idx_on_crawling_log_entry_id_252ef8fe22"
  end

  create_table "solid_cable_messages", force: :cascade do |t|
    t.text "channel"
    t.datetime "created_at", null: false
    t.text "payload"
    t.datetime "updated_at", null: false
    t.index ["channel"], name: "index_solid_cable_messages_on_channel"
    t.index ["created_at"], name: "index_solid_cable_messages_on_created_at"
  end

  create_table "solid_errors", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "exception_class", null: false
    t.string "fingerprint", limit: 64
    t.text "message", null: false
    t.datetime "purge_after", null: false
    t.datetime "resolved_at"
    t.text "severity", null: false
    t.text "source"
    t.datetime "updated_at", null: false
    t.index ["fingerprint"], name: "index_solid_errors_on_fingerprint", unique: true
    t.index ["purge_after"], name: "index_solid_errors_on_purge_after"
    t.index ["resolved_at"], name: "index_solid_errors_on_resolved_at"
  end

  create_table "solid_errors_occurrences", force: :cascade do |t|
    t.text "backtrace"
    t.json "context"
    t.datetime "created_at", null: false
    t.integer "error_id", null: false
    t.datetime "purge_after", null: false
    t.datetime "updated_at", null: false
    t.index ["error_id"], name: "index_solid_errors_occurrences_on_error_id"
    t.index ["purge_after"], name: "index_solid_errors_occurrences_on_purge_after"
  end

  add_foreign_key "solid_errors_occurrences", "solid_errors", column: "error_id"
end
