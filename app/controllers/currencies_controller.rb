class CurrenciesController < VerifyAuthenticateController
  before_action :set_currency, only: %i[ show update destroy ]

  # GET /currencies
  def index
    search = params[:q]
    order_by = params[:order_by]

    @currencies = Currency
      .search(search)
      .page(params[:page])
      .order_field(order_by)

    render json: @currencies
  end

  # GET /currencies/1
  def show
    render json: @currency
  end

  # POST /currencies
  def create
    @currency = Currency.new(currency_params)

    if @currency.save
      render json: @currency, status: :created, location: @currency
    else
      show_error @currency
    end
  end

  # PATCH/PUT /currencies/1
  def update
    if @currency.update(currency_params)
      render json: @currency, status: :accepted
    else
      show_error @currency
    end
  end

  # DELETE /currencies/1
  def destroy
    @currency.destroy
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_currency
    @currency = Currency.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def currency_params
    params.require(:currency).permit(:name, :code, :symbol, :exchange_rate)
  end
end
