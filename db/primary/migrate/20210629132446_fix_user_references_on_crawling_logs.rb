class FixUserReferencesOnCrawlingLogs < ActiveRecord::Migration[6.1]
  def change
    execute "TRUNCATE TABLE crawling_log_entries"

    remove_column :crawling_log_entries, :user_id
    add_reference :crawling_log_entries, :user, index: true, foreign_key: true, type: :uuid
  end
end
