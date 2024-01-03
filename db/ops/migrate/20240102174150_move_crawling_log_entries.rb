class MoveCrawlingLogEntries < ActiveRecord::Migration[7.2]
  def change
    create_table "crawling_log_entries" do |t|
      t.json "raw_data"
      t.string "checksum"
      t.string "failure_message"
      t.datetime "purge_after", null: false
      t.string "purge_method", null: true
      t.boolean "failure", default: false, null: false
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.bigint "user_id"
      t.json "visited_pages"
      t.index ["user_id"], name: "index_crawling_log_entries_on_user_id"
      t.index %w[purge_after purge_method], name: "index_crawling_log_entries_on_purging"

      t.check_constraint "purge_method IN ('deletion', 'destruction')"
    end
  end
end
