class AddBetterIndexToEntries < ActiveRecord::Migration[7.2]
  def change
    remove_index :entries, name: "index_entries_on_user_id_and_item_id_and_date"
    add_index :entries, [:user_id, :timestamp, :item_id, :amount, :created_at]
  end
end
