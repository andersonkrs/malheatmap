class SetEntryUserIdNotNull < ActiveRecord::Migration[6.0]
  def change
    change_column_null :entries, :user_id, false
  end
end
