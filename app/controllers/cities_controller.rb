class CitiesController < ApplicationController
  def index
    search = params[:q]
    order_by = params[:order_by]

    @cities = City
      .search(search)
      .order_field(order_by)
      .page(params[:page])

    render json: @cities
  end
end
