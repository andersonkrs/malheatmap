class CreateUserCrawlableCrawlingLogEntries < ActiveRecord::Migration[6.1]
  def change
    create_table :crawling_log_entries, id: :uuid do |t|
      t.jsonb :raw_data
      t.string :checksum
      t.string :failure_message
      t.boolean :failure, null: false

      t.belongs_to :user, foreign_keys: true, index: true

      t.timestamps
    end
  end
end
