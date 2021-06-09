class AddProcessedAtTimeStamp < ActiveRecord::Migration[6.1]
  def change
    add_column :subscriptions, :processed_at, :timestamp

    execute "UPDATE subscriptions SET processed_at = updated_at WHERE processed IS True"

    remove_column :subscriptions, :processed
  end
end
