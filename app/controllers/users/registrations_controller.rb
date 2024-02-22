# frozen_string_literal: true

class Users::RegistrationsController < Devise::RegistrationsController
  include RackSessionFix

  respond_to :json
  before_action :configure_sign_up_params, only: [:create]
  before_action :configure_account_update_params, only: [:update]

  # GET /resource/sign_up
  # def new
  #   super
  # end

  # POST /resource
  def create
      @customer = Customer.new(customer_params)

      if !@customer.save 
        render json: { errors: @customer.errors }, status: :unprocessable_entity
        return
      end
      
      super do |resource|
        if resource.errors.any?
          @customer.destroy!
        else
          role = Role.find_by(name: USERS_ROLES_CONST[:customer])
          UsersRole.create(role: role, user: resource)
          UsersCustomer.create(user: resource, customer: @customer)
        end
      end
  end

  # GET /resource/edit
  # def edit
  #   super
  # end

  # PUT /resource
  # def update
  #   super
  # end

  # DELETE /resource
  # def destroy
  #   super
  # end

  # GET /resource/cancel
  # Forces the session data which is usually expired after sign
  # in to be expired now. This is useful if the user wants to
  # cancel oauth signing in/up in the middle of the process,
  # removing all OAuth session data.
  # def cancel
  #   super
  # end

  

  # protected

  # If you have extra params to permit, append them to the sanitizer.
  def configure_sign_up_params
    devise_parameter_sanitizer.permit(:sign_up, keys: [:email, :username, :first_name, :last_name, :identity_document])
  end

  # If you have extra params to permit, append them to the sanitizer.
  def configure_account_update_params
    devise_parameter_sanitizer.permit(:account_update, keys: [:first_name, :last_name, :identity_document])
  end

  private 
  
  # Only allow a list of trusted parameters through.
  def customer_params
    params.require(:customer).permit(
      :name,
      :last_name,
      :identity_document,
      :state_id,
      :city_id,
      :address
    )
  end

  # The path used after sign up.
  # def after_sign_up_path_for(resource)
  #   super(resource)
  # end

  # The path used after sign up for inactive accounts.
  # def after_inactive_sign_up_path_for(resource)
  #   super(resource)
  # end
end
