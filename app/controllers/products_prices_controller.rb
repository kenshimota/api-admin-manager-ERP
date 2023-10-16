class ProductsPricesController < ApplicationController
  before_action :set_products_price, only: %i[ show update destroy ]

  # GET /products_prices
  def index
    @products_prices = ProductsPrice.all

    render json: @products_prices
  end

  # GET /products_prices/1
  def show
    render json: @products_price
  end

  # POST /products_prices
  def create
    @products_price = ProductsPrice.new(products_price_params)

    if @products_price.save
      render json: @products_price, status: :created, location: @products_price
    else
      render json: @products_price.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /products_prices/1
  def update
    if @products_price.update(products_price_params)
      render json: @products_price
    else
      render json: @products_price.errors, status: :unprocessable_entity
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
    end

    # Only allow a list of trusted parameters through.
    def products_price_params
      params.require(:products_price).permit(:price, :product_id, :currency_id)
    end
end
