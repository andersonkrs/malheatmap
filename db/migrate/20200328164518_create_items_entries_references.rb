class CreateItemsEntriesReferences < ActiveRecord::Migration[6.0]
  def change
    add_column :entries, :temp_id, :uuid

    execute <<-SQL
      UPDATE entries SET
        temp_id = items.id
      FROM items
      WHERE items.mal_id = item_id
        AND items.kind = item_kind;
    SQL

    remove_column :entries, :item_id
    remove_column :entries, :item_kind
    remove_column :entries, :item_name

    add_column :entries, :item_id, :uuid

    execute <<-SQL
      UPDATE entries SET item_id = temp_id;
    SQL

    remove_column :entries, :temp_id

    change_column_null :entries, :item_id, false
    add_foreign_key :entries, :items, column: :item_id
    add_index :entries, :item_id
  end
end
