require "test_helper"

class SignatureControllerTest < ActionDispatch::IntegrationTest
  test "redirects to the user signature external url" do
    user = users(:babyoda)
    user.signature.attach(io: File.open(file_fixture("user_signature.png")), filename: "#{user.username}.png")

    get user_signature_path(user)

    assert_redirected_to url_for(user.signature)
  end
end
