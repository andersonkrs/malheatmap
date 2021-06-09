module CrawlerTestHelper
  extend ActiveSupport::Concern

  VALID_CRAWLED_DATA = {
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
  }.freeze

  CRAWLED_DATA_EMPTY_HISTORY = {
    profile: {
      avatar_url: "https://dummy/avatar",
      location: "Adelaide, Australia",
      latitude: -34.92866,
      longitude: 138.59863,
      time_zone: "Australia/Adelaide"
    },
    history: []
  }.freeze

  included do
    teardown do
      MAL::UserCrawler.remove_stubs
    end
  end

  def stub_crawler_with_success_response(username)
    MAL::UserCrawler.stub_response(username, VALID_CRAWLED_DATA.dup)
  end
end
