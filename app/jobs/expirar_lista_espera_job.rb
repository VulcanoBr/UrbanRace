class ExpirarListaEsperaJob < ApplicationJob
  queue_as :default

  PRAZO_HORAS = 48

  def perform
    # Busca todos os notificados há mais de 48h que ainda não se inscreveram
    expirados = Waitlist
                  .where(status: "notificado")
                  .where("updated_at < ?", PRAZO_HORAS.hours.ago)
                  .includes(:distance, :event, :category)

    return if expirados.empty?

    expirados.find_each do |waitlist|
      ActiveRecord::Base.transaction do
        waitlist.update_columns(status: "expirado")

        # Verifica se ainda há vagas disponíveis na distância
        # para notificar o próximo da fila imediatamente
        vagas = waitlist.distance.vagas_disponiveis
        if vagas > 0
          NotificarListaEsperaJob.perform_later(waitlist.distance_id, 1)
        end
      end

      Rails.logger.info(
        "[ExpirarListaEsperaJob] Waitlist ##{waitlist.id} expirada — " \
        "atleta #{waitlist.athlete_id} não se inscreveu em #{PRAZO_HORAS}h"
      )
    end
  end
end