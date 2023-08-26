require "test_helper"

class User
  class CrawlDataJobTest < ActiveJob::TestCase
    setup { @user = users(:babyoda) }

    test "executes user crawling without errors" do
      MAL::UserCrawler
        .any_instance
        .stubs(:crawl)
        .returns(
          {
            profile: {
              avatar_url: "https://dummy/avatar",
              location: "Sao Paulo, Brazil",
              latitude: -34.92866,
              longitude: 138.59863,
              time_zone: "America/Sao_Paulo"
            },
            history: []
          }
        )

      assert_changes -> { @user.checksum } do
        User::CrawlDataJob.perform_now(@user)
      end
    end
  end
end
