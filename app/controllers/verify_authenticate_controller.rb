class VerifyAuthenticateController < ApplicationController
  respond_to :json
  before_action :authenticate_user!

  private

  def show_error(model)
    render json: { errors: model.errors }, status: :unprocessable_entity
  end
end
