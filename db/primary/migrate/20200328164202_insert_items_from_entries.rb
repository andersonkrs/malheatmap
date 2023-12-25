class InsertItemsFromEntries < ActiveRecord::Migration[6.0]
  def change
    execute <<-SQL
      INSERT INTO items (mal_id, kind, name, created_at, updated_at)
      SELECT DISTINCT item_id, item_kind, item_name, current_timestamp, current_timestamp FROM entries;
    SQL
  end
end
