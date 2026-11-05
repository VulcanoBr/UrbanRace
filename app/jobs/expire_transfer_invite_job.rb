class ExpireTransferInviteJob < ApplicationJob
  queue_as :default

  def perform(pending_transfer_id)
    pending = PendingTransfer.find_by(id: pending_transfer_id)
    return unless pending
    return unless pending.aguardando?   # já foi aceito ou expirado manualmente
    return unless pending.expirou?      # segurança: só expira se o prazo passou

    PendingTransfer.transaction do
      pending.update!(status: "expirado")
      pending.transfer.update!(status: "expirado")
    end

    # Notifica o cedente que o convite expirou
    TransferMailer.convite_expirado(
      atleta_origem: pending.transfer.athlete_origem,
      pending: pending
    ).deliver_later

    Rails.logger.info "[ExpireTransferInviteJob] PendingTransfer ##{pending_transfer_id} expirado."
  end
end