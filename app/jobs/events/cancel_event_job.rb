# app/jobs/events/cancel_event_job.rb

module Events
  class CancelEventJob < ApplicationJob
    queue_as :critical
    retry_on StandardError, wait: 30.seconds, attempts: 3

    def perform(event_id)
      event = Event.find(event_id)

      # 1. Confirmadas / check-in feito
      event.registrations
           .where(status: %w[confirmed checked_in])
           .includes(:payment, :athlete)          
           .find_each { |reg| process_confirmed(event, reg) }

      # 2. Pendentes
      event.registrations
           .where(status: "pending")
           .includes(:payment, :athlete)          
           .find_each { |reg| process_pending(event, reg) }
    end

    private

    def process_confirmed(event, registration)
      payment = registration.payment

      if payment.nil? || payment.status_cancelado? || payment.status_estornado?
        silent_cancel(registration)
        return
      end

      refund_status = attempt_refund(payment)
      cancel_and_notify(event, registration, refund_status: refund_status)
    end

    def process_pending(event, registration)
      payment = registration.payment

      if payment&.status_pendente?
        payment.cancelar!
        cancel_and_notify(event, registration, refund_status: :not_charged)
      else
        silent_cancel(registration)
      end
    end

    def attempt_refund(payment)
      return :manual_refund if payment.metodo_boleto?
      return :manual_refund if payment.gateway_id.blank?

      Payments::RefundService.call(payment: payment)
      :refunded_automatically

    rescue Payments::RefundService::GatewayError => e
      Rails.logger.warn("[Events::CancelEventJob] Falha gateway — Payment ##{payment.id}: #{e.message}")
      :manual_refund
    rescue => e
      Rails.logger.error("[Events::CancelEventJob] Erro inesperado — Payment ##{payment.id}: #{e.message}")
      :manual_refund
    end

    def silent_cancel(registration)
      registration.update!(status: :cancelado)
    end

    def cancel_and_notify(event, registration, refund_status:)
      registration.update!(status: :cancelado)

      EventCancellationMailer
        .with(registration: registration, refund_status: refund_status)
        .notify_athlete
        .deliver_later
    end
  end
end