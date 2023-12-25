class AddStatusToSubscription < ActiveRecord::Migration[6.0]
  def up
    execute <<-SQL
      CREATE TYPE subscription_status AS ENUM ('pending', 'success', 'error');
    SQL

    add_column :subscriptions, :status, :subscription_status
  end

  def down
    remove_column :subscriptions, :status

    execute <<-SQL
      DROP TYPE subscription_status;
    SQL
  end
end
