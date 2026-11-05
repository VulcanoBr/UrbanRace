
class TransferMailer < ApplicationMailer

  # ── E-mail para quem CEDEU a vaga (transferência imediata) ───────────────
  def transferencia_concluida_origem(atleta:, registration:)
    @atleta       = atleta
    @registration = registration
    @evento       = registration.event

    mail(
      to:      @atleta.email_address,
      subject: "[#{@evento.nome}] Sua vaga foi transferida com sucesso"
    )
  end

  # ── E-mail para quem RECEBEU a vaga (transferência imediata) ─────────────
  def transferencia_concluida_destino(atleta:, registration:)
    @atleta       = atleta
    @registration = registration
    @evento       = registration.event

    mail(
      to:      @atleta.email_address,
      subject: "[#{@evento.nome}] 🎽 Você recebeu uma vaga!"
    )
  end

  # ── E-mail de CONVITE para destinatário sem cadastro ─────────────────────
  def convite_destinatario(pending_transfer:, registration:, atleta_origem:)
    @pending       = pending_transfer
    @registration  = registration
    @evento        = registration.event
    @atleta_origem = atleta_origem

    # Gera token seguro via generates_token_for
    @token = pending_transfer.generate_token_for(:acceptance)

    @url = Rails.application.routes.url_helpers.transfer_invite_url(
      token: @token,
      host:  Rails.application.config.action_mailer.default_url_options[:host]
    )

    @expira_em = pending_transfer.expira_em

    mail(
      to: pending_transfer.email_destino,
      subject: "[#{@evento.nome}] #{@atleta_origem.nome} enviou uma vaga para você!"
    )
  end

  # ── E-mail para quem CEDEU a vaga quando o convite não foi aceito ────────
  def convite_expirado(atleta_origem:, pending:)
    @atleta       = atleta_origem
    @pending      = pending
    @transfer     = pending.transfer
    @registration = pending.registration
    @evento       = @registration.event

    mail(
      to: @atleta.email_address,
      subject: "[#{@evento.nome}] Transferência não aceita dentro do prazo"
    )
  end
end
