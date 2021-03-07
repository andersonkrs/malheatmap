class AddUsersFeatureFlagCountEachEntryAsAnActivity < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :count_each_entry_as_an_activity , :boolean, default: false, null: false
  end
end
