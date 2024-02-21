# frozen_string_literal: true

class Users::SessionsController < Devise::SessionsController
  include RackSessionFix

  respond_to :json
  # before_action :configure_sign_in_params, only: [:create]

  # GET /resource/sign_in
  # def new
  #   super
  # end

  # POST /resource/sign_in
  def create
     super do |resource|
      if resource.persisted?
        render json: current_user, include: [:role, :customer], status: :created
        return
      end
    end
  end

  # DELETE /resource/sign_out
  # def destroy
  #   super
  # end


  protected

  # If you have extra params to permit, append them to the sanitizer.
  def configure_sign_in_params
    devise_parameter_sanitizer.permit(:sign_in, keys: [:username, :password])
  end
end
