# frozen_string_literal: true

class Users::RegistrationsController < Devise::RegistrationsController
  include RackSessionFix

  respond_to :json
  before_action :set_user, only: [:update_role]
  before_action :authenticate_user!, only: [:update_role]
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

  # PUT /resource/:id/role/
  def update_role
    if current_user.nil?
      render json: { error: "Without user" }, status: :unauthorized
      return
    end
    
    if current_user.role.name != USERS_ROLES_CONST[:manager] 
      render json: { error: "Forbidden" }, status: 403
      return
    end

    @role = Role.find_by(name: params[:role][:name])
    @relationship = UsersRole.find_by(user_id: @user.id)
    @relationship.role_id = @role.id

    if !@relationship.save
      render json: { errors: @relationship.errors }, status: :unprocessable_entity
      return       
    end

    render json: @user, include: [:role, :customer], status: :created
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

  def role_params
    params.require(:role).permit(:name)
  end

  def set_user 
    @user = User.find(params[:id])
  end

  def respond_with(resource, _opts = {})
    if resource
      render json: resource, include: [:role, :customer], status: :created
    end
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
