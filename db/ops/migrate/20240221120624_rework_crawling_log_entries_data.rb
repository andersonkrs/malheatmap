class ReworkCrawlingLogEntriesData < ActiveRecord::Migration[7.2]
  def change
    create_table :crawling_log_entry_visited_pages do |t|
      t.belongs_to :crawling_log_entry
      t.string :url
      t.text :body
    end

    remove_column :crawling_log_entries, :visited_pages
  end
end
