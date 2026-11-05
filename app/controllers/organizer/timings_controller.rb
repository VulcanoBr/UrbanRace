class Organizer::TimingsController < Organizer::BaseController
  before_action :set_event

  def create
    unless params[:file].present?
      return redirect_to organizer_event_results_path(@event),
                         alert: "Selecione um arquivo CSV antes de importar."
    end

    relatorio = Operation::TimingImportService.import(params[:file], @event.id)

    # ── Persiste o relatório detalhado no cache (TTL: 10 min) ─────────────
    cache_key = "timing_import_#{Current.user.id}_#{@event.id}_#{Time.current.to_i}"
    Rails.cache.write(cache_key, relatorio.to_h, expires_in: 10.minutes)

    # ── Guarda APENAS a chave leve na session (< 100 bytes) ───────────────
    session[:timing_import_cache_key] = cache_key

    if relatorio.sucesso?
      msg = "#{relatorio.importados} tempo(s) importado(s)"
      msg += ", #{relatorio.atualizados} atualizado(s)" if relatorio.atualizados > 0
      msg += ". #{relatorio.avisos.size} aviso(s)." if relatorio.avisos.any?
      redirect_to organizer_event_results_path(@event), notice: msg
    else
      msg = "#{relatorio.erros.size} erro(s) na importação."
      msg += " #{relatorio.importados} importado(s) com sucesso." if relatorio.importados > 0
      redirect_to organizer_event_results_path(@event), alert: msg
    end
  end

  private

  def set_event
    @event = Current.user.events.find_by!(slug_url: params[:event_id])
  end
end