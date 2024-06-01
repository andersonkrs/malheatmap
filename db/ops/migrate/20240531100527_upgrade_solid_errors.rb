class UpgradeSolidErrors < ActiveRecord::Migration[7.2]
  def up
    execute "DELETE FROM solid_errors_occurrences;"
    execute "DELETE FROM solid_errors;"

    change_column :solid_errors, :exception_class, :text, null: false, limit: nil
    change_column :solid_errors, :message, :text, null: false, limit: nil
    change_column :solid_errors, :severity, :text, null: false, limit: nil
    change_column :solid_errors, :source, :text, null: true, limit: nil
    add_column :solid_errors, :fingerprint, :string, limit: 64
    add_index :solid_errors, :fingerprint, unique: true
    remove_index :solid_errors, [:exception_class, :message, :severity, :source], unique: true
  end

  def down
    change_column :solid_errors, :exception_class, :string, null: false, limit: 200
    change_column :solid_errors, :message, :string, null: false, limit: nil
    change_column :solid_errors, :severity, :string, null: false, limit: 25
    change_column :solid_errors, :source, :string, null: true, limit: nil
    remove_index :solid_errors, [:fingerprint], unique: true
    remove_column :solid_errors, :fingerprint, :string, limit: 64
    add_index :solid_errors, [:exception_class, :message, :severity, :source], unique: true
  end
end
