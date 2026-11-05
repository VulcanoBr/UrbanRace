
class PasswordsController < ApplicationController
  allow_unauthenticated_access
  before_action :set_user_by_token, only: %i[ edit update ]

  def new; end

  def create
    #user_class = params[:user_type] == "organizer" ? Organizer : Athlete
    #PasswordResetService.send_instructions(email_address: params[:email_address], user_class: user_class)
    PasswordResetService.send_instructions( email_address: params[:email_address],
                                            user_type: params[:user_type] )
    redirect_to new_session_path, notice: "Se o e-mail existir, enviaremos as instruções para redefinição da senha."
  end

  def edit; end

  def update
    if @user.update(password_params)
      redirect_to new_session_path, notice: "Sua senha redefinida com sucesso."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_user_by_token
    # Tenta achar em ambas as tabelas se necessário, ou passa user_type no form
    #@user = Athlete.find_by_token_for(:password_reset, params[:token]) || 
     #       Organizer.find_by_token_for(:password_reset, params[:token])
    #redirect_to new_password_path, alert: "Link inválido ou expirado." unless @user

    @user = PasswordTokenService.find_user(params[:token])

    return if @user

    redirect_to new_password_path,
                alert: "Este link é inválido ou expirou."
  end

  def password_params
    params.require(:user).permit(:password, :password_confirmation)
  end
end