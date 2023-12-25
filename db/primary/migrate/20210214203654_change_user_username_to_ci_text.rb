class ChangeUserUsernameToCiText < ActiveRecord::Migration[6.1]
  def change
    enable_extension("citext")

    change_column :users, :username, :citext
  end
end
