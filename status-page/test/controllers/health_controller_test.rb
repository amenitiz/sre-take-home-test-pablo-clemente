require "test_helper"

class HealthControllerTest < ActionDispatch::IntegrationTest
  test "healthz returns 200 with database status" do
    get "/healthz"
    assert_response :ok

    body = JSON.parse(response.body)
    assert_includes body.keys, "database"
    assert_includes body.keys, "timestamp"
  end
end
