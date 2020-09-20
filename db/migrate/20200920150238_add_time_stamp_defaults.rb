class AddTimeStampDefaults < ActiveRecord::Migration[6.0]
  def change
    %i[users entries activities items].each do |table_name|
      change_column_default table_name, :created_at, -> { 'CURRENT_TIMESTAMP' }
      change_column_default table_name, :updated_at, -> { 'CURRENT_TIMESTAMP' }
    end
  end
end
