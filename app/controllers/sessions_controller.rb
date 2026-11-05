
class SessionsController < ApplicationController
  allow_unauthenticated_access only: %i[ new create ]
  rate_limit to: 10, within: 3.minutes, only: :create, with: -> { redirect_to new_session_url, alert: "Muitas tentativas. Tente novamente mais tarde." }

  def new
    # View renderiza o formulário
  end

  def create
    user_class = params[:user_type] == "athlete" ? Athlete : Organizer
    auth = AuthenticationService.new(cookies)

    if session = auth.login(
        email_address: params[:email_address],
        password:      params[:password],
        user_class:    user_class,
        request:       request
      )
      redirect_to after_login_path(session.user), notice: "Bem-vindo ao Urbanrace!"
    else
      flash.now[:alert] = "E-mail ou senha inválidos."
      render :new, status: :unprocessable_content  # ← muda de :unauthorized para :unprocessable_entity
    end
  end

  def destroy
    AuthenticationService.new(cookies).logout
    redirect_to root_path, notice: "Sessão encerrada com sucesso."
  end

  private

  def after_login_path(user)
    return athletes_area_do_corredor_path if user.is_a?(Athlete)

    if user.admin?
      organizer_dashboard_path
    else
      # Staff (operation): vai para seleção de evento
      operation_events_path
    end
  end
end