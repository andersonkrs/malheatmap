class AddItemKindToEntry < ActiveRecord::Migration[6.0]
  def up
    execute <<-SQL
      CREATE TYPE item_kind AS ENUM ('anime', 'manga');
    SQL

    add_column :entries, :item_kind, :item_kind
  end

  def down
    remove_column :entries, :item_kind

    execute <<-SQL
      DROP TYPE item_kind;
    SQL
  end
end
