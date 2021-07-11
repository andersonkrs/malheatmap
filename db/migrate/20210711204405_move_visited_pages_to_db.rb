class MoveVisitedPagesToDb < ActiveRecord::Migration[6.1]
  def change
    add_column :crawling_log_entries, :visited_pages, :json, null: true
  end
end
