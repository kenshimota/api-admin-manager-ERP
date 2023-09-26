require "test_helper"

class WarehousesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @warehouse = warehouses(:one)
  end

  test "should get index" do
    get warehouses_url, as: :json
    assert_response :success
  end

  test "should create warehouse" do
    assert_difference("Warehouse.count") do
      post warehouses_url, params: { warehouse: { address: @warehouse.address, name: @warehouse.name } }, as: :json
    end

    assert_response :created
  end

  test "should show warehouse" do
    get warehouse_url(@warehouse), as: :json
    assert_response :success
  end

  test "should update warehouse" do
    patch warehouse_url(@warehouse), params: { warehouse: { address: @warehouse.address, name: @warehouse.name } }, as: :json
    assert_response :success
  end

  test "should destroy warehouse" do
    assert_difference("Warehouse.count", -1) do
      delete warehouse_url(@warehouse), as: :json
    end

    assert_response :no_content
  end
end
