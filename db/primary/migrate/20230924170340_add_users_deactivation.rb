class AddUsersDeactivation < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :deactivated_at, :datetime, null: true
  end
end
