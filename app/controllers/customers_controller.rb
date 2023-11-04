class CustomersController < VerifyAuthenticateController
  respond_to :json
  before_action :set_customer, only: %i[ show update destroy ]

  # GET /customers
  def index
    search = params[:q]
    order_by = params[:order_by]

    @customers = Customer
      .search(search)
      .city_id(params[:city_id])
      .state_id(params[:state_id])
      .metadata(params[:metadata])
      .order_field(order_by)
      .page(params[:page])

    includes = @customers.first.metadata_fields if @customers.length > 0 and params[:metadata]
    render json: @customers, include: includes
  end

  # GET /customers/1
  def show
    render json: @customer, include: @customer.metadata_fields
  end

  # POST /customers
  def create
    ActiveRecord::Base.transaction do
      data = customer_params.clone
      phones_param = data[:phones]
      data[:phones] = []

      @customer = Customer.create!(data)

      if phones_param
        phones = phones_param.map { |phone_data| Phone.find_or_create_by!(phone_data) }
        phones.each { |phone| @customer.phones << phone }
      end

      render json: @customer, status: :created
    rescue ActiveRecord::RecordInvalid => e
      show_error e.record
      raise ActiveRecord::Rollback
    end
  end

  # PATCH/PUT /customers/1
  def update
    ActiveRecord::Base.transaction do
      data = customer_params.clone
      phones_param = data[:phones]

      if phones_param
        phones = phones_param.map { |phone_data| Phone.find_or_create_by!(phone_data) }
        @customer.phone_ids = phones.map { |phone| phone.id }
      end

      @customer.update!(
        name: data[:name],
        last_name: data[:last_name],
        city_id: data[:city_id],
        address: data[:address],
        state_id: data[:state_id],
        identity_document: data[:identity_document],
      )

      render json: @customer, status: :accepted
    rescue ActiveRecord::RecordInvalid => e
      show_error e.record
      raise ActiveRecord::Rollback
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
    params.require(:customer).permit(
      :name,
      :last_name,
      :identity_document,
      :state_id,
      :city_id,
      :address,
      :phones => [:prefix, :number],
    )
  end
end
