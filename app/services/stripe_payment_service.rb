# app/services/stripe_payment_service.rb
class StripePaymentService
  def initialize(registration)
    @registration = registration
    @athlete = registration.athlete
    @lot = registration.lot
    # Stripe.api_key = Rails.application.credentials.stripe[:secret_key]
  end

  def create_pix_intent
    # Simulação da criação de um PaymentIntent no Stripe para PIX
    # Na vida real, você usaria: Stripe::PaymentIntent.create(...)
    
    payment = @registration.payment || @registration.create_payment!(
      metodo: "pix",
      valor: @lot.preco,
      status: "pendente",
      gateway_provider: "stripe"
    )

    payload_pix = "00020101021226870014br.gov.bcb.pix0114000000000000005204000053039865802BR5913URBANRACE_SYS6009SAO_PAULO62070503***6304"

    # Simulando o retorno do QR Code e ID do Stripe
    {
      client_secret: "pi_simulada_#{SecureRandom.hex(10)}",
      qr_code_base64: "https://api.qrserver.com/v1/create-qr-code/?size=250x250&data=#{payload_pix}",
      qr_code_copy_paste: payload_pix
    }
  end
end