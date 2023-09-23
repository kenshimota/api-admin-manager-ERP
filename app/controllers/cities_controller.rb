class CitiesController < VerifyAuthenticateController
  def index
    search = params[:q]
    cities = City.search(search).page(params[:page])
    render json: cities
  end
end
