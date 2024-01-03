class DropCrawlingLogEntries < ActiveRecord::Migration[7.2]
  def change
    drop_table :crawling_log_entries
  end
end
