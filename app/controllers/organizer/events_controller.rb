class Organizer::EventsController < Organizer::BaseController
  before_action :set_event, only: %i[ show edit update destroy finish cancel ]

  def index
    @events =
      Current.user
             .events
             .order(data_largada: :desc).page(params[:page]).per(10)
  end

  def show
    @event = Current.user.events.find_by!(slug_url: params[:id])
    
    # Contadores para o card de certificados
    @total_homologados = @event.results.homologados.count
    @certificados_gerados = @event.results.homologados.includes(certificate: { arquivo_pdf_attachment: :blob })
                                  .count { |result| result.certificate&.gerado? }
  end

  def new
    @event_form =
      Organizer::EventForm.new
  end

  def create
    @event_form =
      Organizer::EventForm.new(
        event_params.merge(
          organizer_id: Current.user.id
        )
      )

    if @event_form.save
      redirect_to organizer_event_path(@event_form.slug_url),
                notice: "Evento criado com sucesso!"
    else
      render :new,
             status: :unprocessable_entity
    end
  end

  def edit
    @event_form =
      Organizer::EventForm.from_model(@event)
  end

  def update
    @event_form =
      Organizer::EventForm.new(
        event_params.merge(
          id: @event.id,
          organizer_id: Current.user.id
        )
      )

    if @event_form.save
      redirect_to organizer_event_path(@event_form.slug_url),
                  notice: "Evento atualizado!"
    else
      render :edit,
             status: :unprocessable_entity
    end
  end

  def destroy
    @event.destroy

    redirect_to organizer_events_path,
                notice: "Evento removido.",
                status: :see_other
  end

  
  def finish
    unless @event.finishable?
      return redirect_to organizer_event_path(@event),
        alert: "Este evento não pode ser finalizado (status atual: #{@event.status.humanize})."
    end

    blockers = @event.finish_blockers

    if blockers.any?
      flash[:finish_blocked_reasons] = blockers

      return redirect_to organizer_event_path(@event),
        alert: "Não foi possível finalizar o evento. Verifique os impedimentos informados no modal."
    end

    @event.finish!

    redirect_to organizer_event_path(@event),
      notice: "Evento finalizado com sucesso! Os atletas serão notificados por e-mail."

  rescue Errors::InvalidTransition => e
    flash[:finish_blocked_reasons] = @event.finish_blockers

    redirect_to organizer_event_path(@event),
      alert: e.message

  rescue StandardError => e
    Rails.logger.error(
      "[EventsController#finish] #{e.class}: #{e.message}\n#{e.backtrace.first(5).join("\n")}"
    )

    redirect_to organizer_event_path(@event),
      alert: "Ocorreu um erro ao finalizar o evento. Tente novamente."
  end

  def cancel
    blockers = @event.cancellation_blockers

    if blockers.any?
      flash[:cancellation_blocked_reasons] = blockers

      return redirect_to organizer_event_path(@event),
        alert: "Não foi possível cancelar o evento. Verifique os impedimentos informados no modal."
    end

    reason = params[:cancellation_reason].presence

    if reason.blank?
      return redirect_to organizer_event_path(@event),
        alert: "Informe o motivo do cancelamento."
    end

    @event.cancel!(reason: reason)

    redirect_to organizer_event_path(@event),
      notice: "Evento cancelado com sucesso."

  rescue Errors::InvalidTransition => e
    flash[:cancellation_blocked_reasons] = @event.cancellation_blockers

    redirect_to organizer_event_path(@event),
      alert: "Não foi possível cancelar o evento: #{e.message}"

  rescue StandardError => e
    Rails.logger.error(
      "[EventsController#cancel] #{e.class}: #{e.message}\n" \
      "#{e.backtrace.first(5).join("\n")}"
    )

    redirect_to organizer_event_path(@event),
      alert: "Ocorreu um erro ao cancelar o evento. Tente novamente."
  end

  private

  def set_event
    @event =
      Current.user.events.find_by!(slug_url: params[:id])
  end

  def event_params
    params
      .require(:organizer_event_form)
      .permit(
        :nome, :descricao, :cidade, :estado, :local_partida, 
        :data_largada, :horario_largada, :slug_url, :status, 
        :banner, :regulamento,
        # Novos campos permitidos
        :kit_descricao, :cronograma, :instagram_url, 
        :whatsapp_contato, :limite_atletas
      )
  end
end