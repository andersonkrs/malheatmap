class RemoveDuplicatedUsers < ActiveRecord::Migration[6.1]
  def up
    result = ApplicationRecord.connection.execute("SELECT lower(username) FROM users GROUP BY 1 HAVING COUNT(*) > 1")

    result.values.flatten.each do |username|
      users = User.where("username ilike ?", username).to_a
      raise StandardError, "Expected at least 2 users for the username #{username} got #{users.size}" if users.size < 2

      first_user = users.shift

      users.each { |user_to_be_merged| first_user.merge!(user_to_be_merged) }
    end
  end
end
