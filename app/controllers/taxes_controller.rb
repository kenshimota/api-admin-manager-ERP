class TaxesController < VerifyAuthenticateController
  before_action :set_tax, only: [:show, :update, :destroy]

  def index
    search = params[:q]
    order_by = params[:order_by]

    @taxes = Tax
      .search(search)
      .order_field(order_by)
      .page(params[:page])

    render json: @taxes
  end

  def create
    @tax = Tax.new(params_tax)

    if !@tax.save
      return show_error @tax
    end

    render json: @tax, status: :created
  end

  def update
    if !@tax.update(params_tax)
      return show_error @tax
    end

    render json: @tax, status: :accepted
  end

  def destroy
    ActiveRecord::Base.transaction do
      @tax.destroy!
    rescue ActiveRecord::RecordNotDestroyed => e
      render json: { error: I18n.t("tax_dont_delete") }, status: :unprocessable_entity
      raise ActiveRecord::Rollback
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
