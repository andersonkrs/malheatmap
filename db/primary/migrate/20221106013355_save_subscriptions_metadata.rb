class SaveSubscriptionsMetadata < ActiveRecord::Migration[7.1]
  def change
    change_table :subscriptions, bulk: true do |t|
      t.text :redirect_path, null: true
      t.text :process_errors, array: true, default: [], null: false
    end
  end
end
