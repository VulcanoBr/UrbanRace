class Public::PaymentsController < ApplicationController
  allow_unauthenticated_access
  before_action :set_registration

  # GET /registrations/:registration_id/payment
  def show
    # Inscrição já paga? Vai direto para success.
    if @registration.confirmado?
      redirect_to success_registration_payment_path(@registration),
                  notice: "Sua inscrição já está confirmada!"
      return
    end

    @payment_form = Public::PaymentForm.new(registration_id: @registration.id)

    # Usa FakePaymentService em dev/test; StripePaymentService em produção.
    service = payment_service.new(@registration)
    @payment_form.process
    @stripe_data = service.create_pix_intent
  end

  # GET /registrations/:registration_id/payment/success
  def success; end

  # GET /registrations/:registration_id/payment/status  (polling JSON)
  def status
    status_atual = if @registration.confirmado?
                     "pago"
                   else
                     @registration.payment&.status || "pendente"
                   end

    render json: { status: status_atual }
  end

  # POST /registrations/:registration_id/payment/simulate
  # Disponível apenas fora de produção.
  def simulate
    if Rails.env.production?
      head :not_found
      return
    end

    unless @registration.payment
      redirect_to registration_payment_path(@registration),
                  alert: "Nenhum pagamento pendente encontrado. Acesse a tela de pagamento primeiro."
      return
    end

    if @registration.confirmado?
      redirect_to success_registration_payment_path(@registration),
                  notice: "Inscrição já está confirmada!"
      return
    end

    # Garante que o JSON de simulação exista (cria se não existir).
    ensure_fake_payment_json!

    # Enfileira o job que lê o JSON e confirma a inscrição.
    ProcessFakePaymentJob.perform_later(@registration.id)

    # Redireciona para o polling — a página de success
    # é exibida assim que o job terminar e o polling detectar.
    redirect_to registration_payment_path(@registration),
                notice: "Pagamento simulado enviado! Aguardando confirmação..."
  end

  private

  def set_registration
    @registration = Registration.find(params[:registration_id])
  end

  # Seleciona o serviço de pagamento conforme o ambiente.
  def payment_service
    if Rails.env.production?
      StripePaymentService
    else
      FakePaymentService
    end
  end

  # Garante que o arquivo JSON de simulação existe para este registration.
  # Se o FakePaymentService não foi chamado ainda (ex: usuário acessou
  # /simulate diretamente), cria o JSON agora.
  def ensure_fake_payment_json!
    storage_dir = Rails.root.join("tmp", "fake_payments")
    path        = storage_dir.join("#{@registration.id}.json")

    return if File.exist?(path)

    FakePaymentService.new(@registration).create_pix_intent
  end
end
