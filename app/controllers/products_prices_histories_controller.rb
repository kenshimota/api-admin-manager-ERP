class ProductsPricesHistoriesController < VerifyAuthenticateController
  before_action :set_products_prices_history, only: %i[ show ]

  # GET /products_prices_histories
  def index
    search = params[:q]
    includes = [:product, :currency, :tax]
    order_by = params[:order_by]

    @products_prices_histories = ProductsPricesHistory
      .search(search)
      .page(params[:page])
      .currency_id(params[:currency_id])
      .product_id(params[:product_id])
      .order_field(order_by)
      .joins(includes)
      .includes(includes)

    render json: @products_prices_histories, include: includes
  end

  # GET /products_prices_histories/1
  def show
    render json: @products_prices_history, include: [:product, :currency, :tax]
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_products_prices_history
    @products_prices_history = ProductsPricesHistory.find(params[:id])
  end
end
