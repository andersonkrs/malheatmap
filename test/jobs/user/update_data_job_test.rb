require "test_helper"

class User
  class UpdateDataJobTest < ActiveJob::TestCase
    setup do
      @user = create(:user)
    end

    test "calls update data service with given user" do
      service_mock = lambda do |user:|
        assert_equal user, @user
      end

      User::UpdateData.stub(:call!, service_mock) do
        User::UpdateDataJob.perform_now(@user)
      end
    end
  end
end
