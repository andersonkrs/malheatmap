require "test_helper"

class User
  class CrawlDataJobTest < ActiveJob::TestCase
    setup do
      @user = users(:babyoda)
    end

    test "executes user crawling without errors" do
      MAL::UserCrawler.any_instance.stubs(:crawl).returns({
                                                            profile: {
                                                              avatar_url: "https://dummy/avatar",
                                                              location: "Sao Paulo, Brazil",
                                                              latitude: -34.92866,
                                                              longitude: 138.59863,
                                                              time_zone: "America/Sao_Paulo"
                                                            },
                                                            history: []
                                                          })

      assert_changes -> { @user.checksum } do
        User::CrawlDataJob.perform_now(@user)
      end
    end

    test "forwards the error message to the error notifier when the crawling fails" do
      MAL::UserCrawler.any_instance.stubs(:crawl).raises(MAL::Errors::CrawlError.new("Something went wrong"))
      ErrorNotifier.expects(:capture).with("Something went wrong", user: { id: @user.id }).once

      User::CrawlDataJob.perform_now(@user)
    end
  end
end
