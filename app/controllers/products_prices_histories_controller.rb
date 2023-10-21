class ProductsPricesHistoriesController < VerifyAuthenticateController
  before_action :set_products_prices_history, only: %i[ show ]

  # GET /products_prices_histories
  def index
    order_by = params[:order_by]

    @products_prices_histories = ProductsPricesHistory
      .page(params[:page])
      .currency_id(params[:currency_id])
      .product_id(params[:product_id])
      .order_field(order_by)

    render json: @products_prices_histories
  end

  # GET /products_prices_histories/1
  def show
    render json: @products_prices_history
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_products_prices_history
    @products_prices_history = ProductsPricesHistory.find(params[:id])
  end
end
