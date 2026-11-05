# app/jobs/confirm_registration_job.rb

class ConfirmRegistrationJob < ApplicationJob
  queue_as :default

  retry_on ActiveRecord::Deadlocked,
           wait: 5.seconds,
           attempts: 3

  retry_on ActiveRecord::LockWaitTimeout,
           wait: 3.seconds,
           attempts: 5

  def perform(registration_id)
    registration = Registration.find(registration_id)

    Registration.transaction do

      # Recarrega a inscrição com lock
      registration.lock!

      # ---------------------------------------------------
      # IDEMPOTÊNCIA
      # ---------------------------------------------------

      return if registration.confirmado?

      event = registration.event

      # ---------------------------------------------------
      # LOCK NO EVENTO
      # ---------------------------------------------------

      event.with_lock do

        # Recarrega a inscrição após adquirir o lock
        registration.reload

        # Segurança adicional para múltiplos webhooks
        return if registration.confirmado?

        # ---------------------------------------------------
        # GERAÇÃO SEGURA DO DORSAL
        # ---------------------------------------------------

        ultimo_numero =
          event
            .registrations
            .where.not(numero_dorsal: nil)
            .maximum(:numero_dorsal) || 100

        proximo_numero = ultimo_numero + 1

        # ---------------------------------------------------
        # CONFIRMAR INSCRIÇÃO
        # ---------------------------------------------------

        registration.update!(
          status: :confirmado,
          numero_dorsal: proximo_numero
        )

        # ---------------------------------------------------
        # PAGAMENTO
        # ---------------------------------------------------

        registration.payment&.update!(
          status: "pago",
          pago_em: Time.current
        )

        # ---------------------------------------------------
        # ATUALIZAR VAGAS
        # ---------------------------------------------------

        Distance.increment_counter(
          :vagas_ocupadas,
          registration.category.distance_id
        )

        # ---------------------------------------------------
        # FILA DE ESPERA
        # ---------------------------------------------------

        next_in_line =
          Waitlist
            .aguardando
            .where(
              category_id: registration.category_id
            )
            .por_posicao
            .first

        next_in_line&.notificar_vaga_disponivel!
      end
    end

    # ---------------------------------------------------
    # EMAIL
    # ---------------------------------------------------

    RegistrationMailer
      .with(registration: registration)
      .confirmation_email
      .deliver_later
  end
end