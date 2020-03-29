class SyncronizationService
  def initialize(username, crawler)
    @user = User.find_or_initialize_by(username: username)
    @crawler = crawler
    @crawler.requests_interval = Rails.application.config.crawler_requests_interval
  end

  def self.syncronize_user_data(username, crawler = MAL::UserCrawler)
    new(username, crawler).syncronize_user_data
  end

  def syncronize_user_data
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

    import(data)
    generate_activities_from_history

    { status: :success, message: "" }
  end

  def generate_checksum(data)
    json = Marshal.dump(data)
    Digest::MD5.hexdigest(json)
  end

  def import(data)
    profile_data, history = data.values_at(:profile, :history)

    ActiveRecord::Base.transaction do
      import_profile_data(profile_data)
      import_entries(history)
    end
  end

  def import_profile_data(data)
    @user.assign_attributes(**data)
    @user.save!
  end

  def import_entries(history)
    Entry.where(user: @user).last_three_weeks.delete_all

    history.each do |entry|
      item = find_or_create_item(entry)

      Entry.create!(user: @user, item: item, **entry.slice(:amount, :timestamp))
    end
  end

  def find_or_create_item(entry)
    id, kind, name = entry.values_at(:item_id, :item_kind, :item_name)

    Item.find_or_create_by!(mal_id: id, kind: kind, name: name)
  end

  def generate_activities_from_history
    ActivitiesGeneratorService.generate_from_user_history(@user)
  end

  def generate_signature; end

  def pretty_crawler_error(reference, default_message)
    I18n.t(
      "mal.crawler.errors.#{reference}",
      username: @user.username,
      default: default_message
    )
  end
end
