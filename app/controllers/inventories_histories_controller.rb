class InventoriesHistoriesController < VerifyAuthenticateController

  # GET /inventories_histories
  def index
    search = params[:q]
    order_by = params[:order_by]
    includes = [:warehouse, :product, :inventory, :user]

    @inventories_histories = InventoriesHistory
      .search(search)
      .page(params[:page])
      .filter_product(params[:product_id])
      .filter_warehouse(params[:warehouse_id])
      .filter_inventory(params[:inventory_id])
      .order_field(order_by)
      .joins(includes)
      .includes(includes)

    render json: @inventories_histories, include: includes
  end
end
