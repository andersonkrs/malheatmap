class CreateUsers < ActiveRecord::Migration[6.0]
  def change
    create_table :users, id: :uuid do |t|
      t.string :username
      t.string :avatar_url
      t.string :checksum

      t.timestamps
    end

    add_index :users, :username, unique: true
  end
end
