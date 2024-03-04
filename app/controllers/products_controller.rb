class ProductsController < VerifyAuthenticateController
  before_action :set_product, only: %i[ show update destroy ]

  # GET /products
  def index
    search = params[:q]
    order_by = params[:order_by]
    includes = [:tax] if params[:metadata]

    @products = Product
      .search(search)
      .with_stock(params[:with_stock])
      .metadata(params[:metadata])
      .order_field(order_by)
      .page(params[:page])

    render json: @products, include: includes
  end

  # GET /products/1
  def show
    render json: @product, include: [:tax]
  end

  # POST /products
  def create
    @product = Product.new(product_params)

    if @product.save
      render json: @product, status: :created, location: @product
    else
      show_error @product
    end
  end

  # PATCH/PUT /products/1
  def update
    if @product.update(product_params)
      render json: @product, status: :accepted
    else
      show_error @product
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
