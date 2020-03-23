require "test_helper"

class UserUpdateJobTest < ActiveSupport::TestCase
  setup do
    @username = "myfakeuser"
  end

  test "calls update service with given user" do
    stubbed_method = lambda { |username|
      assert_equal @username, username

      { status: :ok }
    }

    UpdateService.stub(:perform, stubbed_method) do
      UserUpdateJob.perform_now(@username)
    end
  end
end
