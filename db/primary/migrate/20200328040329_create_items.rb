class CreateItems < ActiveRecord::Migration[6.0]
  def change
    create_table :items, id: :uuid do |t|
      t.integer :mal_id, null: false
      t.string :name, null: false

      t.timestamps
    end

    add_column :items, :kind, :item_kind, null: false
    add_index :items, %i[mal_id kind], unique: true
  end
end
