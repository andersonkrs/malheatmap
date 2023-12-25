class RemoveSubscriptionUnnecessaryFields < ActiveRecord::Migration[6.0]
  def change
    remove_columns :subscriptions, :reason, :status
    add_column :subscriptions, :processed, :boolean, default: false, null: false

    execute "DROP TYPE subscription_status;"
    execute "UPDATE subscriptions SET processed = true"
  end
end
