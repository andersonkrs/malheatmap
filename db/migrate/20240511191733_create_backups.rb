class CreateBackups < ActiveRecord::Migration[7.2]
  def change
    create_table :backups, id: :bigint do |t|
      t.datetime :started_at
      t.string :key, null: false, index: { unique: true }
      t.string :failure_message, null: true
      t.datetime :finished_at

      t.timestamps
    end
  end
end
