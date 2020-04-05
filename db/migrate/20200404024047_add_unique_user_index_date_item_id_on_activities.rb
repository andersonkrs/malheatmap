class AddUniqueUserIndexDateItemIdOnActivities < ActiveRecord::Migration[6.0]
  def change
    add_index :activities, [:user_id, :item_id, :date], unique: true
  end
end
