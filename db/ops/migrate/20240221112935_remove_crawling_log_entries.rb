class RemoveCrawlingLogEntries < ActiveRecord::Migration[7.2]
  def change
    unless column_exists?(:crawling_log_entries, :purge_method)
      remove_column :crawling_log_entries, :purge_method, if_exists: true
    end
  end
end
