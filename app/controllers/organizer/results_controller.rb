# app/controllers/organizer/results_controller.rb
class Organizer::ResultsController < Organizer::BaseController
  before_action :set_event
  before_action :set_result, only: %i[edit update destroy homologar generate_certificate]

  def index
    # ── Recupera relatório do cache via chave da session ──────────────────
    if (cache_key = session.delete(:timing_import_cache_key))
      raw = Rails.cache.read(cache_key)
      @import_relatorio = raw&.deep_symbolize_keys
    end

    @results = @event.results
                    .includes(:certificate,
                              registration: [:athlete, :distance, :category])
                    .order(:posicao_geral)
                    .page(params[:page]).per(10)

    # Filtros
    @results = @results
      .joins(:registration)
      .where(registrations: { category_id: params[:category_id] }) if params[:category_id].present?

    @results = @results.where(homologado: params[:homologado] == "1") if params[:homologado].present?

    @categorias = @event.categories.includes(:distance).order(:nome)

    # Estatísticas rápidas
    @stats = {
      total:       @event.results.count,
      homologados: @event.results.where(homologado: true).count,
      timings:     Timing.joins(:waypoint, registration: :event)
                         .where(waypoints: { eh_chegada: true })
                         .where(events: { id: @event.id }).count
    }
  end

  def calcular
    relatorio = Operation::ResultCalculatorService.calculate(@event)
    session[:calc_relatorio] = relatorio.to_h

    if relatorio.sucesso?
      redirect_to organizer_event_results_path(@event),
                  notice: "#{relatorio.total} resultado(s) calculado(s) com sucesso!"
    else
      redirect_to organizer_event_results_path(@event),
                  alert: "#{relatorio.erros.size} erro(s) ao calcular. #{relatorio.gerados} criado(s)."
    end
  end

  def homologar_todos
    resultados = @event.results.where(homologado: false)

    count = resultados.update_all(
      homologado: true,
      homologado_em: Time.current
    )

    BatchCertificateJob.perform_later(@event.id) if count.positive?

    redirect_to organizer_event_results_path(@event),
                notice: "#{count} resultado(s) homologado(s). Certificados enviados para geração."
  end

  def homologar
    @result.update!(homologado: true, homologado_em: Time.current)
    redirect_to organizer_event_results_path(@event),
                notice: "Resultado de #{@result.registration.athlete.nome} homologado."
  end

  def edit
    @result_form = Organizer::ResultForm.from_model(@result)
  end

  def update
    @result_form = Organizer::ResultForm.new(
      result_params.merge(id: @result.id, event_id: @event.id)
    )
    if @result_form.save
      redirect_to organizer_event_results_path(@event), notice: "Resultado atualizado!"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @result.destroy
    redirect_to organizer_event_results_path(@event),
                notice: "Resultado excluído.", status: :see_other
  end

  def podium
    @category = @event.categories.find(params[:category_id])
    @winners  = Operation::PodiumGeneratorService.generate(@event, @category)
    render layout: false
  end

  # Exporta CSV dos resultados
  def exportar
    results = @event.results
                    .includes(registration: [:athlete, :distance, :category])
                    .order(:posicao_geral)

    csv = gerar_csv(results)
    send_data csv,
              filename:    "resultados_#{@event.slug_url}_#{Date.today}.csv",
              type:        "text/csv; charset=utf-8",
              disposition: "attachment"
  end

  def generate_certificate
    result = @event.results.find(params[:id])

    unless result.certificado_geravel?
      redirect_to organizer_event_results_path(@event),
                  alert: "Este resultado não está homologado para emissão de certificado."
      return
    end

    Certificates::GenerateSingleJob.perform_later(result.id)

    redirect_to organizer_event_results_path(@event),
                notice: "A geração do certificado de #{@result.registration.athlete.nome} foi iniciada."
  end

  private

  def set_event
    @event = Current.user.events.find_by!(slug_url: params[:event_id])
  end

  def set_result
    @result = @event.results.find(params[:id])
  end

  def result_params
    params.require(:organizer_result_form).permit(
      :registration_id, :posicao_geral, :posicao_categoria,
      :posicao_sexo, :tempo_bruto, :tempo_liquido, :posicao_faixa_etaria,
      :status_finalizacao, :homologado
    )
  end

  def gerar_csv(results)
    require "csv"
    CSV.generate(headers: true, col_sep: ";", encoding: "UTF-8") do |csv|
      csv << %w[Posicao_Geral Posicao_Cat Posicao_Sexo Dorsal Nome Sexo
                Categoria Distancia Tempo_Liquido Tempo_Bruto Pace_Medio
                Status Homologado]

      results.each do |r|
        reg = r.registration
        csv << [
          r.posicao_geral, r.posicao_categoria, r.posicao_sexo,
          reg.numero_dorsal, reg.athlete.nome, reg.athlete.sexo,
          reg.category&.nome, reg.distance&.nome,
          r.tempo_liquido, r.tempo_bruto, r.pace_medio,
          r.status_finalizacao, r.homologado ? "Sim" : "Não"
        ]
      end
    end
  end
end
