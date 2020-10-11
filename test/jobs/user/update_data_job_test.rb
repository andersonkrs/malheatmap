require "test_helper"

class User
  class UpdateDataJobTest < ActiveJob::TestCase
    setup do
      @user = create(:user)
    end

    test "calls update data service with given user" do
      mocked_result = Minitest::Mock.new
      mocked_result.expect(:failure?, false)

      mocked_call = lambda do |user:|
        assert_equal user, @user
        mocked_result
      end

      User::UpdateData.stub(:call, mocked_call) do
        User::UpdateDataJob.perform_now(@user)
      end

      mocked_result.verify
    end
  end
end
