class FakePaymentService
  STORAGE_DIR = Rails.root.join("tmp", "fake_payments")

  def initialize(registration)
    @registration = registration
    @lot          = registration.lot
  end

  # Cria ou reaproveita o Payment e grava o JSON simulado.
  # Retorna um hash compatível com o que @stripe_data espera na view.
  def create_pix_intent
    ensure_storage_dir!

    payment = find_or_create_payment!
    payload = build_payload(payment)

    write_payload!(payload)

    {
      payment_id:        payment.id,
      client_secret:     payload[:gateway_id],
      qr_code_base64:    qr_code_url(payload[:pix_code]),
      qr_code_copy_paste: payload[:pix_code]
    }
  end

  private

  def find_or_create_payment!
    @registration.payment ||
      @registration.create_payment!(
        metodo:           :pix,
        valor:            @lot.preco,
        status:           :pendente,
        gateway_provider: "fake_gateway",
        gateway_id:       "fake_#{SecureRandom.hex(12)}",
        vencimento:       30.minutes.from_now
      )
  end

  def build_payload(payment)
    {
      registration_id: @registration.id,
      payment_id:      payment.id,
      gateway_id:      payment.gateway_id,
      valor:           payment.valor.to_s,
      status:          "paid",              # status que o gateway enviaria
      pix_code:        fake_pix_code,
      created_at:      Time.current.iso8601
    }
  end

  def write_payload!(payload)
    path = STORAGE_DIR.join("#{@registration.id}.json")
    File.write(path, payload.to_json)
  end

  def ensure_storage_dir!
    FileUtils.mkdir_p(STORAGE_DIR)
  end

  # Código PIX EMV mínimo válido para gerar um QR Code visual.
  def fake_pix_code
    "00020101021226870014br.gov.bcb.pix" \
    "0114000000000000005204000053039865802BR" \
    "5913URBANRACE_SYS6009SAO_PAULO" \
    "62070503***6304ABCD"
  end

  # Usa a API gratuita do QR Server para gerar a imagem do QR Code.
  def qr_code_url(pix_code)
    encoded = URI.encode_uri_component(pix_code)
    "https://api.qrserver.com/v1/create-qr-code/?size=250x250&data=#{encoded}"
  end
end
