class ReworkCrawlingLogEntries < ActiveRecord::Migration[7.2]
  def change
    remove_index :crawling_log_entries, name: :index_crawling_log_entries_on_purging
    remove_check_constraint :crawling_log_entries, "purge_method IN ('deletion', 'destruction')"

    add_index :crawling_log_entries, :purge_after, name: :index_crawling_log_entries_on_purging
  end
end
