require "test_helper"

class ServiceTest < ActiveSupport::TestCase
  test "valid service can be created" do
    service = Service.new(name: "API Gateway", url: "https://api.example.com", status: "operational")
    assert service.valid?
  end

  test "requires a name" do
    service = Service.new(url: "https://example.com", status: "operational")
    assert_not service.valid?
    assert_includes service.errors[:name], "can't be blank"
  end

  test "requires a url" do
    service = Service.new(name: "Test Service", status: "operational")
    assert_not service.valid?
    assert_includes service.errors[:url], "can't be blank"
  end

  test "rejects invalid status" do
    service = Service.new(name: "Test", url: "https://example.com", status: "unknown")
    assert_not service.valid?
    assert_includes service.errors[:status], "is not included in the list"
  end

  test "accepts all valid statuses" do
    %w[operational degraded outage maintenance].each do |status|
      service = Service.new(name: "Service #{status}", url: "https://example.com", status: status)
      assert service.valid?, "Expected status '#{status}' to be valid"
    end
  end

  test "operational? returns true for operational services" do
    service = Service.new(status: "operational")
    assert service.operational?
  end

  test "operational? returns false for degraded services" do
    service = Service.new(status: "degraded")
    assert_not service.operational?
  end

  test "status_color returns correct colours" do
    assert_equal "green", Service.new(status: "operational").status_color
    assert_equal "yellow", Service.new(status: "degraded").status_color
    assert_equal "red", Service.new(status: "outage").status_color
    assert_equal "blue", Service.new(status: "maintenance").status_color
  end

  test "default status is operational" do
    service = Service.new(name: "Test", url: "https://example.com")
    assert_equal "maintenance", service.status
  end
end
