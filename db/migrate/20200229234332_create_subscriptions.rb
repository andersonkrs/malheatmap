class CreateSubscriptions < ActiveRecord::Migration[6.0]
  def change
    create_table :subscriptions, id: :uuid do |t|
      t.string :username
      t.string :reason

      t.timestamps
    end
  end
end
