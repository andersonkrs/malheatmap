module CrawledDataTestHelper
  extend ActiveSupport::Concern

  def valid_crawled_data
    JSON.parse(file_fixture("user_crawled_data.json").read, symbolize_names: true)
  end
end
