require "test_helper"

class HttpClient::RequestsTest < ActiveSupport::TestCase
  using HttpClient::NetHttpRefinements

  class ApiClient < HttpClient::Base
    self.site = "https://jsonplaceholder.typicode.com"
    self.content_type = :json

    def fetch_post(id:)
      get("/posts/#{id}")
    end

    def create_post(title:, body:)
      post("/posts", body: {
        title: title,
        body: body,
        userId: 1
      })
    end
  end

  test "can execute a GET request and return a response" do
    VCR.use_cassette("json_placeholder_fetch_todo_1") do
      response = ApiClient.fetch_post(id: 1)

      assert response.is_a?(Net::HTTPSuccess)
      assert_equal 1, response.parsed["id"]
    end
  end

  test "can execute a POST request and return a response" do
    VCR.use_cassette("json_placeholder_create_todo") do
      response = ApiClient.create_post(title: "foo", body: "bar")

      assert response.is_a?(Net::HTTPCreated)
      assert_equal "foo", response.parsed["title"]
      assert_equal "bar", response.parsed["body"]
    end
  end
end
