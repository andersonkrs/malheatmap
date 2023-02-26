class CreateAccessTokens < ActiveRecord::Migration[7.1]
  def change
    create_table :access_tokens, id: :bigint do |t|
      t.string :token
      t.string :refresh_token
      t.datetime :token_expires_at
      t.datetime :refresh_token_expires_at

      t.references :user, foreign_key: true, index: true, type: :uuid

      t.timestamps
    end
  end
end
