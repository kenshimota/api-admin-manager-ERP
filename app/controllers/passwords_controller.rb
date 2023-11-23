class PasswordsController < Devise::PasswordsController
  before_action :set_user, only: [:create, :update]

  def create

    # Generate and store/reset the 6-digit code
    if !@user.update(reset_code: "%06d" % rand(1000000), reset_code_sent_at: Time.now.utc)
      render json: resource.errors, status: :unprocessable_entity
      return
    end

    # Send instructions email with the code
    PasswordsMailer
      .with(user: resource)
      .reset_password
      .deliver_later

    render json: { message: I18n.t("devise.mailer.reset_password_instructions.sent") }, status: :created
  end

  def update
    if @user.reset_code.nil? or @user.reset_code.to_i != params[:user][:reset_code].to_i
      render json: { "errors": { "reset_token": [I18n.t("errors.messages.invalid")] } }, status: :unprocessable_entity
      return
    end

    if @user.reset_code_sent_at.nil? or @user.reset_code_sent_at < 1.hour.ago
      render json: { "errors": { "reset_token": [I18n.t("errors.messages.expired")] } }, status: :unprocessable_entity
      return
    end

    if !@user.update(password: params[:user][:password], reset_code: nil, reset_code_sent_at: nil)
      render json: { errors: @user.errors }, status: :unprocessable_entity
      return
    end

    render json: { message: I18n.t("devise.passwords.updated_not_active") }, status: :accepted
  end

  private

  def send_reset_password_instructions_with_code(record)
    # Use Devise's mailer to send the password reset email
    Devise::Mailer.reset_password_instructions(record, record.reset_password_token, code: record.reset_code).deliver_now
  end

  def set_user
    @user = User.find_by(email: resource_params[:email])
  end
end
