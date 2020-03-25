require "test_helper"

class SyncronizeDataTest < ActiveSupport::TestCase
  def invoke
    Rake::Task["syncronize_data"].invoke
  end

  test "performs update service for all users" do
    create_list(:user, 6)

    performed_count = 0
    stubbed_method = proc { |_username|
      performed_count += 1
    }

    SyncronizationService.stub :syncronize_user_data, stubbed_method do
      invoke
    end

    assert 6, performed_count
  end

  test "keeps processing when some user fails to update" do
    create(:user, username: "a")
    create(:user, username: "b")

    performed_count = 0
    stubbed_method = proc { |username|
      raise StandardError if username == "a"

      performed_count += 1
    }

    SyncronizationService.stub :syncronize_user_data, stubbed_method do
      invoke
    end

    assert 1, performed_count
  end
end
