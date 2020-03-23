class UpdateService
  def initialize(username, crawler)
    @user = User.find_or_initialize_by(username: username)
    @crawler = crawler
    @crawler.requests_interval = Rails.application.config.crawler_requests_interval
  end

  def self.perform(username, crawler = MAL::UserCrawler)
    self.new(username, crawler).perform
  end

  def perform
    data = @crawler.crawl(@user.username)

    process_data(data)
  rescue MAL::Errors::CrawlError => error
    { status: :error, message: pretty_crawler_error(error.reference, error.message) }
  end

  private

  def process_data(data)
    @user.checksum = generate_checksum(data)
    unless @user.checksum_changed?
      return { status: :not_processed, message: "User #{@user.username} hasn't new data" }
    end

    profile, history = data.values_at(:profile, :history)
    save(profile, history)

    { status: :success, message: "" }
  end

  def generate_checksum(data)
    json = Marshal.dump(data)
    Digest::MD5.hexdigest(json)
  end

  def save(profile_data, history)
    ActiveRecord::Base.transaction do
      @user.update!(**profile_data)

      Entry.where(user: @user).last_three_weeks.delete_all

      history.each do |entry|
        Entry.create!(user: @user, **entry)
      end
    end
  end

  def pretty_crawler_error(reference, default_message)
  I18n.t(
      "mal.crawler.errors.#{reference}",
      username: @user.username,
      default: default_message
    )
  end
end
