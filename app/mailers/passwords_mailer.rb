class PasswordsMailer < ApplicationMailer
  def reset_password
    @user = params[:user]
    mail to: @user.email, subject: I18n.t("devise.mailer.reset_password_instructions.subject")
  end
end
