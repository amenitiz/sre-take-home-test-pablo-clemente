require "test_helper"

class ServicesControllerTest < ActionDispatch::IntegrationTest
  setup do
    Service.delete_all
    @service = Service.create!(name: "Test Service", url: "https://example.com", status: "operational")
  end

  test "index renders successfully" do
    get services_url
    assert_response :success
  end

  test "root path shows services index" do
    get root_url
    assert_response :success
  end

  test "show renders a service" do
    get service_url(@service)
    assert_response :success
  end

  test "new renders the form" do
    get new_service_url
    assert_response :success
  end

  test "create makes a new service" do
    assert_difference("Service.count") do
      post services_url, params: { service: { name: "New Service", url: "https://new.example.com", status: "operational" } }
    end
    assert_redirected_to service_url(Service.last)
  end

  test "update changes a service" do
    patch service_url(@service), params: { service: { name: "Updated Name" } }
    assert_redirected_to service_url(@service)
    assert_equal "Updated Name", @service.reload.name
  end

  test "destroy removes a service" do
    assert_difference("Service.count", -1) do
      delete service_url(@service)
    end
    assert_redirected_to services_url
  end
end
