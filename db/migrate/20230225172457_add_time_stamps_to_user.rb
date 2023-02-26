class AddTimeStampsToUser < ActiveRecord::Migration[7.1]
  def change
    change_table :users, bulk: true do |t|
      t.datetime :profile_data_updated_at, null: true
      t.datetime :anime_list_snapshot_updated_at, null: true
      t.datetime :manga_list_snapshot_updated_at, null: true
    end
  end
end
