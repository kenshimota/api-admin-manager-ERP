class ProductsPricesHistoriesController < ApplicationController
  before_action :set_products_prices_history, only: %i[ show update destroy ]

  # GET /products_prices_histories
  def index
    @products_prices_histories = ProductsPricesHistory.all

    render json: @products_prices_histories
  end

  # GET /products_prices_histories/1
  def show
    render json: @products_prices_history
  end

  # POST /products_prices_histories
  def create
    @products_prices_history = ProductsPricesHistory.new(products_prices_history_params)

    if @products_prices_history.save
      render json: @products_prices_history, status: :created, location: @products_prices_history
    else
      render json: @products_prices_history.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /products_prices_histories/1
  def update
    if @products_prices_history.update(products_prices_history_params)
      render json: @products_prices_history
    else
      render json: @products_prices_history.errors, status: :unprocessable_entity
    end
  end

  # DELETE /products_prices_histories/1
  def destroy
    @products_prices_history.destroy
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_products_prices_history
      @products_prices_history = ProductsPricesHistory.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def products_prices_history_params
      params.require(:products_prices_history).permit(:products_price_id, :user_id, :price_before, :price_after)
    end
end
