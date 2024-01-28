require "test_helper"

class User::CrawlerPipelineTest < ActiveSupport::TestCase
  setup do
    @user = users(:babyoda)
    @crawler_response = {
      profile: {
        avatar_url: "https://dummy/avatar",
        location: "Adelaide, Australia",
        latitude: -34.92866,
        longitude: 138.59863,
        time_zone: "Australia/Adelaide"
      },
      history: [
        {
          timestamp: Time.find_zone("Australia/Adelaide").local(2020, 10, 3, 17, 30),
          amount: 1,
          item_id: 121,
          item_name: "Death Note",
          item_kind: "manga"
        },
        {
          timestamp: Time.find_zone("Australia/Adelaide").local(2020, 10, 2, 3, 17),
          amount: 6,
          item_id: 5,
          item_name: "One Punch Man",
          item_kind: "anime"
        },
        {
          timestamp: Time.find_zone("Australia/Adelaide").local(2020, 10, 1, 19, 55),
          amount: 4,
          item_id: 5,
          item_name: "One Punch Man",
          item_kind: "anime"
        },
        {
          timestamp: Time.find_zone("Australia/Adelaide").local(2020, 10, 1, 19, 30),
          amount: 3,
          item_id: 5,
          item_name: "One Punch Man",
          item_kind: "anime"
        }
      ]
    }

    MAL::UserCrawler.any_instance.stubs(:crawl).returns(@crawler_response)
  end

  test "updates user profile data and inserts all entries to user parsing the natural timestamps correctly" do
    @user.crawler_pipeline.execute!

    assert @user.checksum.present?
    assert_equal "https://dummy/avatar", @user.avatar_url
    assert_equal "Adelaide, Australia", @user.location
    assert_equal(-34.92866, @user.latitude)
    assert_equal 138.59863, @user.longitude
    assert_equal "Australia/Adelaide", @user.time_zone

    assert_equal 4, @user.entries.count
    entries = @user.entries.order(timestamp: :desc)
    entry = entries.first
    assert_equal Time.find_zone(@user.time_zone).local(2020, 10, 3, 17, 30), entry.timestamp
    assert_equal 1, entry.amount
    assert_equal 121, entry.mal_id
    assert_equal "Death Note", entry.name
    assert_equal "manga", entry.kind

    entry = entries.second
    assert_equal Time.find_zone(@user.time_zone).local(2020, 10, 2, 3, 17), entry.timestamp
    assert_equal 6, entry.amount
    assert_equal 5, entry.mal_id
    assert_equal "One Punch Man", entry.name
    assert_equal "anime", entry.kind

    entry = entries.third
    assert_equal Time.find_zone(@user.time_zone).local(2020, 10, 1, 19, 55), entry.timestamp
    assert_equal 4, entry.amount
    assert_equal 5, entry.mal_id
    assert_equal "One Punch Man", entry.name
    assert_equal "anime", entry.kind

    entry = entries.last
    assert_equal Time.find_zone(@user.time_zone).local(2020, 10, 1, 19, 30), entry.timestamp
    assert_equal 3, entry.amount
    assert_equal 5, entry.mal_id
    assert_equal "One Punch Man", entry.name
    assert_equal "anime", entry.kind

    assert_equal 3, @user.activities.count

    assert_enqueued_with job: User::Signaturable::SignatureImage::GenerateJob, args: [@user]

    perform_enqueued_jobs only: CrawlingLogEntry::SaveAsyncJob

    assert_equal 1, @user.crawling_log_entries.count
    crawling_log_entry = @user.crawling_log_entries.first
    assert_equal crawling_log_entry.checksum, @user.checksum
    assert_equal false, crawling_log_entry.failure?
    assert crawling_log_entry.purge_with_deletion?
    assert_nil crawling_log_entry.failure_message
    assert_equal @crawler_response, crawling_log_entry.raw_data.deep_symbolize_keys
  end

  test "updates item name if it has changed" do
    entry_data = @crawler_response[:history].first
    item = Item.create!(mal_id: entry_data[:item_id], kind: entry_data[:item_kind], name: "Old Name")

    @user.crawler_pipeline.execute!

    assert_changes -> { item.name }, from: "Old Name", to: entry_data[:item_name] do
      item.reload
    end
  end

  test "does not delete user entries if just the profile changed" do
    @user.entries.create!(timestamp: 5.days.ago, item: items(:boruto), amount: 10)
    @crawler_response[:history] = []

    assert_no_changes -> { @user.entries.count } do
      @user.crawler_pipeline.execute!
    end
  end

  test "updates user data when the new data checksum changes" do
    travel_to Date.new(2020, 10, 3)
    @user.crawler_pipeline.execute!
    @crawler_response[:profile][:avatar_url] = "https://dummy/new_avatar"

    assert_changes -> { @user.checksum } do
      @user.crawler_pipeline.execute!
      @user.reload
    end

    perform_enqueued_jobs only: CrawlingLogEntry::SaveAsyncJob
    assert_equal 2, @user.crawling_log_entries.count

    crawling_log_entries = @user.crawling_log_entries.order(:created_at)
    previous_crawling_log = crawling_log_entries.first
    current_crawling_log = crawling_log_entries.second

    assert_equal "https://dummy/new_avatar", @user.avatar_url
    assert_not_equal previous_crawling_log.checksum, current_crawling_log.checksum
    assert_not_equal @user.checksum, previous_crawling_log.checksum
    assert_equal @user.checksum, current_crawling_log.checksum
  end

  test "does not destroy entries older that the oldest present on the crawled data payload" do
    travel_to Time.zone.local(2020, 10, 3, 20, 0, 0)

    entry_to_be_destroyed = {
      timestamp: Time.zone.local(2020, 10, 1, 20, 0, 0),
      item: items(:one_punch_man),
      amount: 1
    }
    entry_not_to_be_destroyed = { timestamp: Time.zone.local(2020, 9, 30), item: items(:one_punch_man), amount: 2 }
    @user.entries.create!([entry_not_to_be_destroyed, entry_to_be_destroyed])

    @user.crawler_pipeline.execute!

    assert_not @user.entries.exists?(entry_to_be_destroyed)
    assert @user.entries.exists?(entry_not_to_be_destroyed)
  end

  test "raises an error if the oldest crawled entry is older than 30 days" do
    @user.entries.create!([timestamp: Time.zone.now, item: items(:one_punch_man), amount: 2])
    @crawler_response[:history].first[:timestamp] = 30.days.ago.in_time_zone

    assert_raises User::MALSyncable::ScrapedData::DeletingOldHistoryNotAllowed do
      @user.crawler_pipeline.execute!
    end

    assert_equal 1, @user.entries.count
  end

  test "saves the navigation history" do
    MAL::UserCrawler
      .any_instance
      .stubs(:history)
      .returns(
        [
          stub(body: "<html>profile</html>", uri: URI.parse("https://dummy/myuser/profile")),
          stub(body: "<html>history</html>", uri: URI.parse("https://dummy/myuser/history"))
        ]
      )
    @user.crawler_pipeline.execute!

    perform_enqueued_jobs only: CrawlingLogEntry::SaveAsyncJob

    visited_pages = @user.crawling_log_entries.first.visited_pages

    assert_equal 2, visited_pages.size
    assert_includes visited_pages, { "body" => "<html>profile</html>", "path" => "/myuser/profile" }
    assert_includes visited_pages, { "body" => "<html>history</html>", "path" => "/myuser/history" }
  end

  test "does not update user's data when checksum did not change" do
    travel_to Date.new(2020, 10, 3)

    @user.crawler_pipeline.execute!
    perform_enqueued_jobs only: [User::Signaturable::SignatureImage::GenerateJob]

    @user.reload

    assert_no_changes -> { @user.attributes.except("updated_at") } do
      @user.crawler_pipeline.execute!
    end

    assert_no_changes -> { @user.entries.count } do
      @user.crawler_pipeline.execute!
    end

    assert_no_changes -> { @user.activities.count } do
      @user.crawler_pipeline.execute!
    end

    assert_no_enqueued_jobs(only: [User::Signaturable::SignatureImage::GenerateJob]) { @user.crawler_pipeline.execute! }
  end

  test "updates signature if the checksum dit not change but the last signature date changed" do
    travel_to Date.new(2020, 10, 3)

    @user.crawler_pipeline.execute!

    travel_to 2.days.from_now

    assert_enqueued_with job: User::Signaturable::SignatureImage::GenerateJob, args: [@user] do
      @user.crawler_pipeline.execute!
    end
  end

  test "does not schedule deactivation for linked account when retuning a profile not found error" do
    @user = User.create(username: "bigjoe", mal_id: 123_123)

    MAL::UserCrawler.any_instance.stubs(:crawl).raises(MAL::Errors::ProfileNotFound)

    assert_raises MAL::Errors::ProfileNotFound do
      @user.crawler_pipeline.execute!
    end

    assert_no_enqueued_jobs(only: User::Deactivatable::DeactivationJob)
  end

  test "creates a log entry with the failure message and an error occurs during the crawling" do
    MAL::UserCrawler
      .any_instance
      .stubs(:history)
      .returns([stub(body: "<html>something wrong here</html>", uri: URI.parse("https://dummy/myuser/profile"))])
    MAL::UserCrawler.any_instance.stubs(:crawl).raises(MAL::Errors::CrawlError.new("Something wrong here"))

    assert_raises MAL::Errors::CrawlError do
      @user.crawler_pipeline.execute!
    end

    perform_enqueued_jobs only: CrawlingLogEntry::SaveAsyncJob

    assert_equal 1, @user.crawling_log_entries.count
    log_entry = @user.crawling_log_entries.first
    assert_equal true, log_entry.failure?
    assert_equal "Something wrong here", log_entry.failure_message

    visited_pages = log_entry.visited_pages

    assert_equal 1, visited_pages.size
    assert_equal "/myuser/profile", visited_pages.first["path"]
    assert_equal "<html>something wrong here</html>", visited_pages.first["body"]
  end
end
