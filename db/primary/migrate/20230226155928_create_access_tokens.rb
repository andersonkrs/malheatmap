class CreateAccessTokens < ActiveRecord::Migration[7.1]
  def change
    create_table :access_tokens, id: :bigint do |t|
      t.string :token
      t.string :refresh_token
      t.datetime :token_expires_at
      t.datetime :refresh_token_expires_at

      t.datetime :discarded_at, null: true

      t.references :user, foreign_key: true, type: :uuid, index: { unique: true, where: "(discarded_at IS NULL)" }

      t.timestamps
    end
  end
end
