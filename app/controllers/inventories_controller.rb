class InventoriesController < VerifyAuthenticateController
  before_action :set_inventory, only: %i[ show update destroy ]

  # GET /inventories
  def index
    @inventories = Inventory
      .page(params[:page])
      .filter_product(params[:product_id])
      .filter_warehouse(params[:warehouse_id])

    render json: @inventories
  end

  # GET /inventories/1
  def show
    render json: @inventory
  end

  # POST /inventories
  def create
    @inventory = Inventory.new(inventory_params)
    @inventory.set_user current_user

    if @inventory.save
      render json: @inventory, status: :created
    else
      show_error @inventory
    end
  end

  # PATCH/PUT /inventories/1
  def update
    ActiveRecord::Base.transaction do
      data = inventory_params.to_h
      stock = inventory_params[:stock] - @inventory.stock
      data.delete(:stock)

      @inventory.set_user current_user
      @inventory.increment_stock! stock

      if data.size > 0
        @inventory.update! data
      end

      render json: @inventory, status: :accepted
    rescue ActiveRecord::RecordInvalid => e
      show_error e.record
      raise ActiveRecord::Rollback
    end
  end

  # DELETE /inventories/1
  def destroy
    @inventory.destroy
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_inventory
    @inventory = Inventory.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def inventory_params
    params.require(:inventory).permit(:product_id, :stock, :warehouse_id, :observations)
  end
end
