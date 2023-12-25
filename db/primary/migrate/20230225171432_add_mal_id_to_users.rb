class AddMALIdToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :mal_id, :integer, null: true
    add_index :users, %i[mal_id], unique: true
  end
end
