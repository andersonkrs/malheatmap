class AddCrawlerPerformedAtToUsers < ActiveRecord::Migration[7.2]
  def up
    add_column :users, :mal_synced_at, :datetime, null: true
    execute "UPDATE users SET mal_synced_at = updated_at;"
  end

  def down
    remove_column :users, :mal_synced_at
  end
end
