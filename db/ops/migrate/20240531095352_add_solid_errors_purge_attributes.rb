class AddSolidErrorsPurgeAttributes < ActiveRecord::Migration[7.2]
  def change
    execute "DELETE FROM solid_errors_occurrences;"
    execute "DELETE FROM solid_errors;"

    change_table :solid_errors do |t|
      t.datetime :purge_after, null: false, default: -> { 'CURRENT_TIMESTAMP' }, index: true
    end

    change_table :solid_errors_occurrences do |t|
      t.datetime :purge_after, null: false, default: -> { 'CURRENT_TIMESTAMP' }, index: true
    end
  end
end
