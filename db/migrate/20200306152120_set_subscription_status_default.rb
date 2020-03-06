class SetSubscriptionStatusDefault < ActiveRecord::Migration[6.0]
  def change
    change_column :subscriptions, :status, :subscription_status, default: "pending", null: false
  end
end
