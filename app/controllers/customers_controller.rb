class CustomersController < VerifyAuthenticateController
  respond_to :json
  before_action :set_customer, only: %i[ show update destroy ]

  # GET /customers
  def index
    search = params[:q]
    order_by = params[:order_by]

    @customers = Customer
      .search(search)
      .order_field(order_by)
      .page(params[:page])

    render json: @customers
  end

  # GET /customers/1
  def show
    render json: @customer
  end

  # POST /customers
  def create
    @customer = Customer.new(customer_params)

    if @customer.save
      render json: @customer, status: :created, location: @customer
    else
      show_error @customer
    end
  end

  # PATCH/PUT /customers/1
  def update
    if @customer.update(customer_params)
      render json: @customer, status: :accepted
    else
      show_error @customer
    end
  end

  # DELETE /customers/1
  def destroy
    @customer.destroy
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_customer
    @customer = Customer.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def customer_params
    params.require(:customer).permit(:name, :last_name, :identity_document, :state_id, :city_id, :address)
  end
end
