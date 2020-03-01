class CreateEntries < ActiveRecord::Migration[6.0]
  def change
    create_table :entries, id: :uuid do |t|
      t.timestamp :timestamp
      t.integer :amount
      t.integer :item_id
      t.string :item_name
      t.references :user, foreign_key: true, index: true, type: :uuid

      t.timestamps
    end

    add_index :entries, :timestamp
  end
end
