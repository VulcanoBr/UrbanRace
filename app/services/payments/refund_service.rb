# app/services/payments/refund_service.rb
#
# Responsável por chamar a API do gateway e marcar o pagamento como estornado.
# Suporta: Stripe, MercadoPago, PagSeguro — detectado via payment.gateway_provider.
#
# Uso:
#   Payments::RefundService.call(payment: payment)
#
# Lança GatewayError se o gateway recusar ou retornar erro.
#
module Payments
  class RefundService
    class GatewayError < StandardError; end

    def self.call(payment:)
      new(payment).call
    end

    def initialize(payment)
      @payment = payment
    end

    def call
      raise GatewayError, "Pagamento não está pago." unless @payment.status_pago?
      raise GatewayError, "gateway_id ausente."       if @payment.gateway_id.blank?

      process_refund_via_gateway
      @payment.estornar!

      Rails.logger.info(
        "[Payments::RefundService] Estorno OK — Payment ##{@payment.id} " \
        "via #{@payment.gateway_provider} (#{@payment.gateway_id})"
      )
    end

    private

    def process_refund_via_gateway
      case @payment.gateway_provider&.downcase
      when "stripe"
        refund_via_stripe
      when "mercadopago"
        refund_via_mercadopago
      when "pagseguro"
        refund_via_pagseguro
      else
        raise GatewayError,
          "Gateway '#{@payment.gateway_provider}' não suportado para estorno automático."
      end
    end

    # ── Stripe ───────────────────────────────────────────────────────────

    def refund_via_stripe
      # Requer gem 'stripe' configurada com Rails.application.credentials.stripe.secret_key
      #
      # refund = Stripe::Refund.create(
      #   payment_intent: @payment.gateway_id,
      #   reason:         "requested_by_customer"
      # )
      # raise GatewayError, "Stripe recusou: #{refund.failure_reason}" if refund.status != "succeeded"
      #
      # ⚠ Descomente e configure a gem Stripe para ativar em produção.
      raise GatewayError, "Stripe: configure a gem e descomente o código em RefundService."
    end

    # ── MercadoPago ──────────────────────────────────────────────────────

    def refund_via_mercadopago
      # Requer gem 'mercadopago-sdk' ou chamada HTTP direta.
      #
      # sdk = Mercadopago::SDK.new(Rails.application.credentials.mercadopago.access_token)
      # response = sdk.refund.create(@payment.gateway_id)
      # raise GatewayError, response[:response]["message"] if response[:status] >= 400
      #
      # ⚠ Descomente e configure para ativar em produção.
      raise GatewayError, "MercadoPago: configure a SDK e descomente o código em RefundService."
    end

    # ── PagSeguro ────────────────────────────────────────────────────────

    def refund_via_pagseguro
      # Requer integração via API REST do PagSeguro.
      #
      # response = Faraday.post(
      #   "https://api.pagseguro.com/charges/#{@payment.gateway_id}/cancel",
      #   { amount: { value: (@payment.valor * 100).to_i } }.to_json,
      #   "Authorization" => "Bearer #{Rails.application.credentials.pagseguro.token}",
      #   "Content-Type"  => "application/json"
      # )
      # raise GatewayError, "PagSeguro erro: #{response.status}" unless response.success?
      #
      # ⚠ Descomente e configure para ativar em produção.
      raise GatewayError, "PagSeguro: configure a integração e descomente em RefundService."
    end
  end
end
