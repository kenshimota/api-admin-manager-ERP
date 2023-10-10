class InventoriesHistoriesController < VerifyAuthenticateController

  # GET /inventories_histories
  def index
    @inventories_histories = InventoriesHistory
      .page(params[:page])
      .filter_product(params[:product_id])
      .filter_warehouse(params[:warehouse_id])
      .filter_inventory(params[:inventory_id])

    render json: @inventories_histories
  end
end
