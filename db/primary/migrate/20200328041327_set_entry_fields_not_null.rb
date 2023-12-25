class SetEntryFieldsNotNull < ActiveRecord::Migration[6.0]
  def change
    change_column_null :entries, :timestamp, false
    change_column_null :entries, :amount, false
  end
end
