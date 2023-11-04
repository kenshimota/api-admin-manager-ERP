class OrdersController < VerifyAuthenticateController
  before_action :set_order, only: [:destroy, :show]

  def index
    search = params[:q]
    order_by = params[:order_by]
    includes = [:user, :currency, :orders_status, :customer] if params[:metadata]

    @orders = Order
      .search(search)
      .page(params[:page])
      .order_field(order_by)
      .metadata(params[:metadata])
      .currency_id(params[:currency_id])
      .customer_id(params[:customer_id])
      .orders_status_id(params[:orders_status_id])
      .user_id(params[:user_id])

    render json: @orders, include: includes
  end

  def show
    render json: @order, include: [:user, :currency, :orders_status, :customer]
  end

  def destroy
    ActiveRecord::Base.transaction do
      @order.destroy!
    rescue ActiveRecord::RecordNotDestroyed => e
      show_error e.record
      raise ActiveRecord::Rollback
    end
  end

  private

  def set_order
    @order = Order.joins(:user, :currency, :orders_status, :customer).find(params[:id])
  end
end
