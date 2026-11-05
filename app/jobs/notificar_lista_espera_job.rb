class NotificarListaEsperaJob < ApplicationJob
  queue_as :mailers

  # Se o job falhar (ex: problema de e-mail), tenta novamente
  retry_on StandardError, wait: 2.minutes, attempts: 3

  def perform(distance_id, vagas_disponiveis)
    distance = Distance.find_by(id: distance_id)
    return unless distance

    # Busca apenas os atletas aguardando nesta distância,
    # ordenados pela posição na fila, limitados ao número de vagas
    lista = Waitlist
              .aguardando
              .where(distance_id: distance_id)
              .por_posicao
              .limit(vagas_disponiveis)
              .includes(:athlete, :event, :category)

    return if lista.empty?

    lista.each do |waitlist|
      # Marca como notificado ANTES de enviar o e-mail
      # para evitar duplo envio em caso de retry do job
      next if waitlist.status == "notificado"

      waitlist.update_columns(status: "notificado")
      WaitlistMailer.vaga_disponivel(waitlist).deliver_later
    end

    Rails.logger.info(
      "[NotificarListaEsperaJob] Distância ##{distance_id}: " \
      "#{lista.size} atleta(s) notificado(s) de #{vagas_disponiveis} vaga(s) abertas"
    )
  end
end