class User::Incineration
  def initialize(user)
    @user = user
  end

  def perform
    loop do
      destroyed = @user.activities.limit(500).destroy_all

      break if destroyed.empty?
    end

    loop do
      destroyed = @user.entries.limit(500).destroy_all

      break if destroyed.empty?
    end

    @user.destroy!
  end
end
