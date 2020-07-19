require "test_helper"

class GenerateUserSignatureTest < ActiveSupport::TestCase
  setup do
    travel_to Date.new(2020, 5, 1)

    @user = create(:user)
    create(:activity, user: @user, amount: 6, date: Date.new(2020, 5, 1))
    create(:activity, user: @user, amount: 4, date: Date.new(2020, 4, 4))
    create(:activity, user: @user, amount: 3, date: Date.new(2020, 3, 14))
    create(:activity, user: @user, amount: 2, date: Date.new(2020, 2, 20))
    create(:activity, user: @user, amount: 1, date: Date.new(2020, 1, 1))
    create(:activity, user: @user, amount: 30, date: Date.new(2019, 12, 1))
    create(:activity, user: @user, amount: 20, date: Date.new(2019, 11, 15))
    create(:activity, user: @user, amount: 10, date: Date.new(2019, 10, 2))
    create(:activity, user: @user, amount: 9, date: Date.new(2019, 9, 12))
    create(:activity, user: @user, amount: 8, date: Date.new(2019, 8, 7))
    create(:activity, user: @user, amount: 7, date: Date.new(2019, 7, 26))
    create(:activity, user: @user, amount: 5, date: Date.new(2019, 6, 30))
  end

  test "generates user signature correctly using current date" do
    GenerateUserSignature.call!(user: @user)

    assert @user.signature.attached?
    @user.signature.blob.open do |file|
      fixture = File.join(file_fixture_path, "user_signature.png")
      FileUtils.cp(file.path, fixture) unless File.file?(fixture)

      assert_equal Imatcher.compare(file.path, fixture, threshold: 0.5).match?, true
    end
  end
end
