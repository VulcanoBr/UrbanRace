class Public::RegistrationsController < ApplicationController
  allow_unauthenticated_access
  before_action :set_event

  def new
    # Redireciona se vier sem distance_id (refresh manual, link direto, etc.)
    unless params[:distance_id].present?
      redirect_to public_event_path(@event.slug_url),
                  alert: "Selecione uma distância para se inscrever."
      return
    end

    @distance = @event.distances.find_by(id: params[:distance_id])

    # Protege também contra distance_id inválido
    unless @distance
      redirect_to public_event_path(@event.slug_url),
                  alert: "Distância não encontrada."
      return
    end

    @current_lot = @distance.lots.atuais.first

    if @current_lot.nil?
      redirect_to public_event_path(@event.slug_url),
                  alert: "Inscrições encerradas para esta distância."
      return
    end

    @distance_sold_out = @distance.sold_out? || @current_lot.vagas_disponiveis <= 0

    @registration_form = Public::RegistrationForm.new(
      event_id:    @event.id,
      distance_id: @distance.id,
      lot_id:      @current_lot.id
    )
  end

  def create
    @registration_form = Public::RegistrationForm.new(
      registration_params.merge(event_id: @event.id)
    )

    # Carrega distância e lote antes de salvar — necessário para re-render correto
    @distance = @event.distances.find_by(id: @registration_form.distance_id)
    @current_lot = @distance&.lots&.find_by(id: @registration_form.lot_id)

    # Segurança: se distância ou lote sumirem entre new e create
    unless @distance && @current_lot
      redirect_to public_event_path(@event.slug_url),
                  alert: "Ocorreu um problema. Por favor, selecione a distância novamente."
      return
    end

    result = @registration_form.save(current_athlete)

    case result
    when true
      unless authenticated?
        atleta = @registration_form.registration.athlete
        session_record = atleta.sessions.create!(
          ip_address: request.remote_ip,
          user_agent: request.user_agent
        )
        cookies.signed.permanent[:session_id] = {
          value:     session_record.id,
          httponly:  true,
          same_site: :lax
        }
      end
      redirect_to registration_payment_path(@registration_form.registration),
                  notice: "Inscrição iniciada! Conclua o pagamento para garantir sua vaga."

    when :waitlist
      redirect_to root_path, #public_event_path(@event.slug_url),
                  notice: "Você foi adicionado à lista de espera na posição ##{@registration_form.waitlist_entry.posicao}. Avisaremos por e-mail quando uma vaga abrir!"

    else
      @show_waitlist_option = @distance.sold_out? ||
                              @current_lot.vagas_disponiveis <= 0

      render :new, status: :unprocessable_entity
    end
  end

  private

  def set_event
    @event = Event.published.find_by!(slug_url: params[:slug])
  end

  def registration_params
    params.require(:public_registration_form).permit(
      :nome, :email_address, :cpf, :nascimento, :sexo, :telefone, :password,
      :distance_id, :category_id, :lot_id, :tamanho_kit, :atestado_file,
      :contato_emergencia, :fone_emergencia, :aceite_lgpd, :join_waitlist
    )
  end
end