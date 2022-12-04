class AddLocationFieldsToUser < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :location, :string
    add_column :users, :time_zone, :string, default: "UTC", null: false
    add_column :users, :latitude, :float
    add_column :users, :longitude, :float
  end
end
