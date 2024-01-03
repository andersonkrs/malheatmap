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

ActiveRecord::Schema[7.2].define(version: 2024_01_02_174150) do
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
    t.json "visited_pages"
    t.index ["purge_after", "purge_method"], name: "index_crawling_log_entries_on_purging"
    t.index ["user_id"], name: "index_crawling_log_entries_on_user_id"
    t.check_constraint "purge_method IN ('deletion', 'destruction')"
  end

end
