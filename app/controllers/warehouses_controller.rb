class WarehousesController < VerifyAuthenticateController
  before_action :set_warehouse, only: %i[ show update destroy ]

  # GET /warehouses
  def index
    search = params[:q]
    order_by = params[:order_by]

    @warehouses = Warehouse.all
=begin
    @warehouses = Warehouse
      .search(search)
      .order_field(order_by)
      .page(params[:page])
=end

    render json: @warehouses
  end

  # GET /warehouses/1
  def show
    render json: @warehouse
  end

  # POST /warehouses
  def create
    @warehouse = Warehouse.new(warehouse_params)
    if @warehouse.save
      render json: @warehouse, status: :created
    else
      render json: @warehouse.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /warehouses/1
  def update
    if @warehouse.update(warehouse_params)
      render json: @warehouse, status: :accepted
    else
      render json: @warehouse.errors, status: :unprocessable_entity
    end
  end

  # DELETE /warehouses/1
  def destroy
    @warehouse.destroy
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_warehouse
    @warehouse = Warehouse.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def warehouse_params
    params.require(:warehouse).permit(:name, :address)
  end
end
