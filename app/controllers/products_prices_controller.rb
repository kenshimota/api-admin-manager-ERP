class ProductsPricesController < VerifyAuthenticateController
  before_action :set_products_price, only: %i[ show update destroy ]

  # GET /products_prices
  def index
    search = params[:q]
    order_by = params[:order_by]
    includes = [:product, :tax, :currency] if params[:metadata]

    @products_prices = ProductsPrice
      .search(search)
      .page(params[:page])
      .currency_id(params[:currency_id])
      .product_id(params[:product_id])
      .metadata(params[:metadata])
      .available(params[:available])
      .filter_order(params[:filter_order_id])
      .order_field(order_by)

    render json: @products_prices, include: includes
  end

  # GET /products_prices/1
  def show
    render json: @products_price, include: [:product, :tax, :currency]
  end

  # POST /products_prices
  def create
    @products_price = ProductsPrice.new(products_price_params)
    @products_price.set_user current_user

    if @products_price.save
      render json: @products_price, status: :created
    else
      show_error @products_price
    end
  end

  # PATCH/PUT /products_prices/1
  def update
    if @products_price.update(products_price_params)
      render json: @products_price, status: :accepted
    else
      show_error @products_price
    end
  end

  # DELETE /products_prices/1
  def destroy
    @products_price.destroy
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_products_price
    @products_price = ProductsPrice.find(params[:id])
    @products_price.set_user current_user
    @products_price
  end

  # Only allow a list of trusted parameters through.
  def products_price_params
    params.require(:products_price).permit(:price, :product_id, :currency_id)
  end
end
