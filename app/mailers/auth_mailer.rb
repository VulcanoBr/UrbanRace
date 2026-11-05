# app/mailers/auth_mailer.rb

class AuthMailer < ApplicationMailer
  self.deliver_later_queue_name = :mailers

  default from: "UrbanRace <noreply@urbanrace.com.br>"

  def password_reset
    @user  = params[:user]
    @token = params[:token]

    @reset_url = edit_password_url(@token)

    mail(
      to: @user.email_address,
      subject: "Redefinição de senha - UrbanRace"
    )
  end
end