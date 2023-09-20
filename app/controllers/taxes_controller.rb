class TaxesController < VerifyAuthenticateController
  before_action :set_tax, only: [:show, :update, :destroy]

  def index
    search = params[:q]
    taxes = Tax.search(search).page(params[:page])
    render json: taxes
  end

  def create
    @tax = Tax.new(params_tax)

    if !@tax.save
      return show_error @tax
    end

    render json: @tax, status: :created
  end

  def show
    render json: @tax
  end

  def update
    if !@tax.update(params_tax)
      return show_error @tax
    end

    render json: @tax, status: :ok
  end

  def destroy
    if !@tax
      return render status: :not_found
    end

    if !@tax.destroy
      return show_error @tax
    end
  end

  private

  def set_tax
    @tax = Tax.find(params[:id])
  end

  def params_tax
    params.require(:tax).permit(:name, :percentage)
  end
end
