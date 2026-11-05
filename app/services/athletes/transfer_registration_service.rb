# app/services/athletes/transfer_registration_service.rb

class Athletes::TransferRegistrationService
  class TransferError < StandardError
  end

  def self.aceitar_convite(
    pending_transfer:,
    athlete_attributes:
  )
    new(
      registration: pending_transfer.registration,
      atleta_origem_id: pending_transfer.transfer.athlete_origem_id
    ).aceitar_convite(
      pending_transfer,
      athlete_attributes
    )
  end

  # ===========================================================================
  # ENTRY POINT — DESTINATÁRIO JÁ CADASTRADO
  # ===========================================================================

  def self.executar_imediato(
    registration:,
    atleta_destino:,
    atleta_origem_id:
  )
    new(
      registration: registration,
      atleta_origem_id: atleta_origem_id
    ).executar_imediato(atleta_destino)
  end

  # ===========================================================================
  # ENTRY POINT — DESTINATÁRIO NÃO CADASTRADO
  # ===========================================================================

  def self.executar_com_convite(
    registration:,
    email_destino:,
    cpf_destino:,
    atleta_origem_id:
  )
    new(
      registration: registration,
      atleta_origem_id: atleta_origem_id
    ).executar_com_convite(
      email_destino,
      cpf_destino
    )
  end

  def initialize(registration:, atleta_origem_id:)
    @registration     = registration
    @atleta_origem_id = atleta_origem_id
  end

  # ===========================================================================
  # TRANSFERÊNCIA IMEDIATA
  # ===========================================================================

  def executar_imediato(atleta_destino)
    Registration.transaction do
      validar_pre_condicoes!(atleta_destino)

      nova_inscricao = criar_inscricao_destino(atleta_destino)

      transferir_pagamento(nova_inscricao)

      marcar_origem_como_transferida

      registrar_transfer_concluido(
        atleta_destino.id,
        nova_inscricao
      )

      notificar_transferencia_concluida(
        atleta_destino,
        nova_inscricao
      )
    end
  end

  # ===========================================================================
  # TRANSFERÊNCIA POR CONVITE
  # ===========================================================================

  def executar_com_convite(email_destino, cpf_destino)
    Registration.transaction do
      validar_pre_condicoes!

      email_destino = email_destino.to_s.downcase.strip
      cpf_destino    = cpf_destino.to_s.gsub(/\D/, "")

      # ============================================================
      # CPF JÁ EXISTE
      # ============================================================

      atleta_destino = Athlete.find_by(cpf: cpf_destino)

      if atleta_destino.present?
        validar_destinatario_sem_inscricao!(atleta_destino)
        validar_destinatario_elegibilidade!(atleta_destino)

        return executar_imediato(atleta_destino)
      end

      # ============================================================
      # E-MAIL JÁ EXISTE
      # ============================================================

      if Athlete.exists?(email_address: email_destino)
        raise TransferError,
              "O e-mail informado já pertence a um atleta cadastrado."
      end

      # ============================================================
      # CRIA TRANSFER
      # ============================================================

      transfer = Transfer.create!(
        registration_id: @registration.id,
        athlete_origem_id: @atleta_origem_id,
        athlete_destino_id: nil,
        status: "pendente",
        taxa: 0,
        solicitada_em: Time.current,
        email_destino: email_destino,
        cpf_destino: cpf_destino
      )

      # ============================================================
      # CRIA CONVITE
      # ============================================================

      pending = PendingTransfer.create!(
        transfer: transfer,
        registration: @registration,
        email_destino: email_destino,
        cpf_destino: cpf_destino,
        status: "aguardando",
        expira_em: 48.hours.from_now
      )

      # ============================================================
      # EXPIRAÇÃO
      # ============================================================

      ExpireTransferInviteJob
        .set(wait: 48.hours)
        .perform_later(pending.id)

      # ============================================================
      # E-MAIL
      # ============================================================

      TransferMailer
        .convite_destinatario(
          pending_transfer: pending,
          registration: @registration,
          atleta_origem: Athlete.find(@atleta_origem_id)
        )
        .deliver_later

      pending
    end
  end

  private

  attr_reader :registration, :atleta_origem_id

  def aceitar_convite(
    pending_transfer,
    athlete_attributes
  )

    Registration.transaction do

      # ============================================================
      # CONVITE
      # ============================================================

      unless pending_transfer.aguardando?
        raise TransferError,
              "Este convite não está mais disponível."
      end

      if pending_transfer.expirou?
        pending_transfer.update!(
          status: "expirado"
        )

        raise TransferError,
              "Este convite expirou."
      end

      # ============================================================
      # CRIA ATLETA
      # ============================================================

      atleta = Athlete.new(athlete_attributes)

      atleta.cpf =
        pending_transfer.cpf_destino

      atleta.email_address =
        pending_transfer.email_destino

      unless atleta.save
        raise TransferError,
              atleta.errors.full_messages.to_sentence
      end

      # ============================================================
      # VALIDA REGRAS
      # ============================================================

      validar_pre_condicoes!(atleta)

      validar_destinatario_sem_inscricao!(
        atleta
      )

      validar_destinatario_elegibilidade!(
        atleta
      )

      # ============================================================
      # CRIA NOVA INSCRIÇÃO
      # ============================================================

      nova_inscricao =
        criar_inscricao_destino(atleta)

      # ============================================================
      # TRANSFERE PAGAMENTO
      # ============================================================

      transferir_pagamento(
        nova_inscricao
      )

      # ============================================================
      # MARCA ORIGINAL
      # ============================================================

      marcar_origem_como_transferida

      # ============================================================
      # TRANSFER
      # ============================================================

      transfer =
        pending_transfer.transfer

      transfer.update!(
        status: "concluido",
        athlete_destino_id: atleta.id,
        concluida_em: Time.current
      )

      # ============================================================
      # PENDING TRANSFER
      # ============================================================

      pending_transfer.update!(
        status: "aceito",
        athlete_destino_id: atleta.id
      )

      # ============================================================
      # E-MAILS
      # ============================================================

      notificar_transferencia_concluida(
        atleta,
        nova_inscricao
      )

      atleta
    end
  end

  # ===========================================================================
  # PRÉ-CONDIÇÕES DA INSCRIÇÃO
  # ===========================================================================

  def validar_pre_condicoes!(atleta_destino = nil)
    reg = Registration
      .lock
      .includes(:event, :athlete_checkins, :category)
      .find(registration.id)

    raise TransferError,
          "Inscrição não está confirmada." unless reg.confirmado?

    raise TransferError,
          "Check-in já realizado." if reg.athlete_checkins.exists?

    raise TransferError,
          "Evento não permite transferências." \
      if reg.event.finished? || reg.event.cancelled?

    raise TransferError,
          "Inscrição já foi transferida." if reg.transferido?

    if atleta_destino.present?

      inscricao_existente = Registration
        .where(
          athlete_id: atleta_destino.id,
          event_id: reg.event_id
        )
        .where.not(
          status: %w[cancelled transferred]
        )
        .exists?

      if inscricao_existente
        raise TransferError,
              "O atleta destinatário já possui uma inscrição neste evento. A transferência não pode ser realizada."
      end

      #validar_destinatario_sem_inscricao!( atleta_destino )

      validar_destinatario_elegibilidade!( atleta_destino )
    end

    reg
  end

  # ===========================================================================
  # DESTINATÁRIO NÃO PODE TER INSCRIÇÃO NO EVENTO
  # ===========================================================================

  def validar_destinatario_sem_inscricao!(atleta_destino)
    return unless atleta_destino

    inscricao_existente = Registration
      .where(
        athlete_id: atleta_destino.id,
        event_id: registration.event_id
      )
      .where.not(
        status: %w[
          cancelled
          transferred
          
        ]
      )
      .exists?

    if inscricao_existente
      raise TransferError,
            "O atleta #{atleta_destino.nome} já possui uma inscrição ativa neste evento. A transferência não pode ser realizada."
    end
  end

  # ===========================================================================
  # CRIA NOVA INSCRIÇÃO
  # ===========================================================================

  def criar_inscricao_destino(atleta_destino)
    ultimo_dorsal = registration
      .event
      .registrations
      .where.not(numero_dorsal: nil)
      .maximum(:numero_dorsal) || 100

    Registration.create!(
      athlete_id:          atleta_destino.id,
      event_id:            registration.event_id,
      distance_id:         registration.distance_id,
      category_id:         registration.category_id,
      lot_id:              registration.lot_id,
      status:              "confirmed",
      tamanho_kit:         registration.tamanho_kit,
      data_inscricao:      Time.current,
      qr_code_hash:        SecureRandom.hex(16),
      numero_dorsal:       ultimo_dorsal + 1,
      aceite_lgpd:         true,
      atestado_enviado:    false,
      contato_emergencia:  nil,   # preenchido pelo atleta depois
      fone_emergencia:     nil,   # preenchido pelo atleta depois
      transferencia:       true   # ← suprime validações de contato/fone
    )
  end

  # ===========================================================================
  # TRANSFERE PAGAMENTO
  # ===========================================================================

  def transferir_pagamento(nova_inscricao)
    pagamento = registration.payment

    return unless pagamento

    pagamento.update!(
      registration_id: nova_inscricao.id
    )
  end

  # ===========================================================================
  # MARCA INSCRIÇÃO ORIGINAL
  # ===========================================================================

  def marcar_origem_como_transferida
    registration.update!(
      status: "transferred"
    )
  end

  # ===========================================================================
  # HISTÓRICO
  # ===========================================================================

  def registrar_transfer_concluido(
    atleta_destino_id,
    nova_inscricao
  )
    Transfer.create!(
      registration_id: registration.id,
      athlete_origem_id: atleta_origem_id,
      athlete_destino_id: atleta_destino_id,
      email_destino: nova_inscricao.athlete.email_address,
      cpf_destino: nova_inscricao.athlete.cpf,
      status: "concluido",
      taxa: 0,
      solicitada_em: Time.current,
      concluida_em: Time.current
    )
  end

  # ===========================================================================
  # E-MAILS
  # ===========================================================================

  def notificar_transferencia_concluida(
    atleta_destino,
    nova_inscricao
  )
    atleta_origem = Athlete.find(
      atleta_origem_id
    )

    TransferMailer
      .transferencia_concluida_origem(
        atleta: atleta_origem,
        registration: registration
      )
      .deliver_later

    TransferMailer
      .transferencia_concluida_destino(
        atleta: atleta_destino,
        registration: nova_inscricao
      )
      .deliver_later
  end

  def validar_destinatario_elegibilidade!(atleta_destino)
    erros =
      registration.category.erros_de_elegibilidade(
        atleta_destino,
        reference_date: registration.event.data_largada.to_date
      )

    return if erros.empty?

    raise TransferError, erros.join(" ")
  end
end