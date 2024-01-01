class InvoicesController < VerifyAuthenticateController
  def create
    @order = Order
      .joins(:user, :currency, :orders_status, :customer)
      .where(id: params[:invoice][:order_id])
      .first

    if !@order
      render json: { errors: { order_id: [I18n.t("errors.messages.blank")] } }, status: :unprocessable_entity
      return
    end

    status = OrdersStatus.where(name: ORDER_STATUSES_NAME[:invoiced]).first

    @order.set_user current_user
    @order.update!(orders_status_id: status.id)

    render json: @order, include: [:user, :currency, :orders_status, :customer], status: :created
  end

  private

  # Only allow a list of trusted parameters through.
  def invoice_params
    params.require(:invoice).permit(:order_id)
  end
end
