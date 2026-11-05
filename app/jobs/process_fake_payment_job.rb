class ProcessFakePaymentJob < ApplicationJob
  queue_as :default

  STORAGE_DIR = Rails.root.join("tmp", "fake_payments")

  def perform(registration_id)
    # ── 1. Ler o arquivo JSON ─────────────────────────────────────────
    path = STORAGE_DIR.join("#{registration_id}.json")

    unless File.exist?(path)
      Rails.logger.warn(
        "[ProcessFakePaymentJob] JSON não encontrado para " \
        "registration_id=#{registration_id}. Abortando."
      )
      return
    end

    payload = JSON.parse(File.read(path), symbolize_names: true)

    # ── 2. Sanidade básica ────────────────────────────────────────────
    unless payload[:registration_id].to_i == registration_id.to_i
      Rails.logger.error(
        "[ProcessFakePaymentJob] registration_id no JSON " \
        "(#{payload[:registration_id]}) difere do esperado " \
        "(#{registration_id}). Abortando."
      )
      return
    end

    unless payload[:status] == "paid"
      Rails.logger.info(
        "[ProcessFakePaymentJob] Status no JSON é " \
        "'#{payload[:status]}' — não é 'paid'. Abortando."
      )
      return
    end

    # ── 3. Atualizar o Payment com o gateway_id do JSON ───────────────
    registration = Registration.find_by(id: registration_id)

    unless registration
      Rails.logger.error(
        "[ProcessFakePaymentJob] Registration #{registration_id} " \
        "não encontrada. Abortando."
      )
      return
    end

    # Idempotência: já confirmada? Nada a fazer.
    if registration.confirmado?
      Rails.logger.info(
        "[ProcessFakePaymentJob] Registration #{registration_id} " \
        "já está confirmada. Pulando."
      )
      cleanup!(path)
      return
    end

    # Sincroniza o gateway_id no Payment (útil para rastrear em produção)
    registration.payment&.update_columns(
      gateway_id: payload[:gateway_id]
    )

    # ── 4. Delegar ao job real de confirmação ─────────────────────────
    ConfirmRegistrationJob.perform_now(registration_id)

    Rails.logger.info(
      "[ProcessFakePaymentJob] ConfirmRegistrationJob executado " \
      "para registration_id=#{registration_id}."
    )

    # ── 5. Limpar o arquivo após processar ────────────────────────────
    cleanup!(path)
  end

  private

  def cleanup!(path)
    File.delete(path) if File.exist?(path)
  end
end
