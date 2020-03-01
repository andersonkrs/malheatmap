class SetUserFieldsNotNull < ActiveRecord::Migration[6.0]
  def change
    change_column_null :users, :username, false
  end
end
