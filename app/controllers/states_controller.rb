class StatesController < VerifyAuthenticateController
  def index
    search = params[:q]
    states = State.search(search).page(params[:page])
    render json: states
  end
end
