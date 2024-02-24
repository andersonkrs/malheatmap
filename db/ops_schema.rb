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

ActiveRecord::Schema[7.2].define(version: 2024_02_21_120624) do
  create_table "crawling_log_entries", force: :cascade do |t|
    t.json "raw_data"
    t.string "checksum"
    t.string "failure_message"
    t.datetime "purge_after", null: false
    t.string "purge_method"
    t.boolean "failure", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.binary "data"
    t.index ["purge_after"], name: "index_crawling_log_entries_on_purging"
    t.index ["user_id"], name: "index_crawling_log_entries_on_user_id"
  end

  create_table "crawling_log_entry_visited_pages", force: :cascade do |t|
    t.integer "crawling_log_entry_id"
    t.string "url"
    t.text "body"
    t.index ["crawling_log_entry_id"], name: "idx_on_crawling_log_entry_id_252ef8fe22"
  end
end
