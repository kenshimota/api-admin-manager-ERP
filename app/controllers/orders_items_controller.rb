class OrdersItemsController < VerifyAuthenticateController
  respond_to :json
  before_action :set_item, only: [:show, :destroy]

  def index
    order_by = params[:order_by]
    includes = [:product, :order, :currency, :customer] if params[:metadata]

    @items = OrdersItem
      .page(params[:page])
      .order_field(order_by)
      .order_id(params[:order_id])
      .product_id(params[:product_id])
      .currency_id(params[:currency_id])
      .customer_id(params[:customer_id])
      .metadata(params[:metadata])

    render json: @items, include: includes
  end

  def show
    render json: @item, include: [:product, :order, :currency, :customer]
  end

  def create
    @item = OrdersItem.new(item_params)
    if @item.save
      render json: @item, status: :created, location: @item
    else
      show_error @item
    end
  end

  def destroy
    ActiveRecord::Base.transaction do
      @item.destroy!
    rescue ActiveRecord::RecordNotDestroyed => e
      show_error e.record
      raise ActiveRecord::Rollback
    end
  end

  private

  # Only allow a list of trusted parameters through.
  def item_params
    params.require(:item).permit(:product_id, :order_id, :quantity)
  end

  def set_item
    @item = OrdersItem.find(params[:id])
  end
end
