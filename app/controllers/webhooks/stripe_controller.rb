# app/controllers/webhooks/stripe_controller.rb
class Webhooks::StripeController < ApplicationController
  skip_before_action :require_authentication
  skip_before_action :verify_authenticity_token # Webhooks não usam CSRF

  def create
    payload = request.body.read
    # Na vida real: sig_header = request.env['HTTP_STRIPE_SIGNATURE']
    # event = Stripe::Webhook.construct_event(payload, sig_header, endpoint_secret)

    # Simulação de evento 'payment_intent.succeeded'
    # Extraímos o metadata ou ID que enviamos na criação
    registration_id = params[:data][:object][:metadata][:registration_id]
    
    # Enfileira o job no Solid Queue para confirmar a inscrição
    ConfirmRegistrationJob.perform_later(registration_id)

    head :ok
  end
end