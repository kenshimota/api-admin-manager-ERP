class StatesController < VerifyAuthenticateController
  def index
    search = params[:q]
    order_by = params[:order_by]

    @states = State
      .search(search)
      .order_field(order_by)
      .page(params[:page])

    render json: @states
  end
end
