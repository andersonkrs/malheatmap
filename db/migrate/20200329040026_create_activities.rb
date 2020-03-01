class CreateActivities < ActiveRecord::Migration[6.0]
  def change
    create_table :activities, id: :uuid do |t|
      t.references :user, null: false, foreign_key: true, index: true, type: :uuid
      t.references :item, null: false, foreign_key: true, index: true, type: :uuid
      t.date :date, null: false
      t.integer :amount, null: false

      t.timestamps
    end
  end
end
