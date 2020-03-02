class UpdateService
  include CallableService

  def initialize(username, crawler_service = CrawlerService)
    @user = User.find_or_initialize_by(username: username)
    @crawler_service = crawler_service
  end

  def call
    update_data
    result
  end

  private

  attr_reader :user, :new_checksum, :result, :crawler_service

  def update_data
    response = crawler_service.call(user.username)
    status, message, profile, entries = response.values_at(:status, :message, :profile, :entries)

    case status
    when :success
      process_data(profile, entries)
    when :error
      @result = { status: :error, message: message }
    end
  end

  def process_data(profile, entries)
    generate_checksum(entries)

    unless checksum_changed?
      @result = { status: :not_processed, message: "User #{user.username} hasn't new entries" }
      return
    end

    save(profile, entries)
    @result = { status: :success, message: "" }
  end

  def generate_checksum(entries)
    json = Marshal.dump(entries)
    @new_checksum = Digest::MD5.hexdigest(json)
  end

  def checksum_changed?
    user.checksum != new_checksum
  end

  def save(profile_data, entries)
    ActiveRecord::Base.transaction do
      user.update!(checksum: new_checksum, **profile_data)

      Entry.where(user: user).last_three_weeks.delete_all

      entries.each do |entry|
        Entry.create!(user: user, **entry)
      end
    end
  end
end
