class ProductsController < VerifyAuthenticateController
  before_action :set_product, only: %i[ show update destroy ]

  # GET /products
  def index
    search = params[:q]
    order_by = params[:order_by]

    @products = Product
      .search(search)
      .order_field(order_by)
      .page(params[:page])

    render json: @products
  end

  # GET /products/1
  def show
    render json: @product
  end

  # POST /products
  def create
    @product = Product.new(product_params)

    if @product.save
      render json: @product, status: :created, location: @product
    else
      render json: @product.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /products/1
  def update
    if @product.update(product_params)
      render json: @product, status: :accepted
    else
      render json: @product.errors, status: :unprocessable_entity
    end
  end

  # DELETE /products/1
  def destroy
    @product.destroy
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_product
    @product = Product.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def product_params
    params.require(:product).permit(:name, :code, :bar_code, :tax_id)
  end
end
