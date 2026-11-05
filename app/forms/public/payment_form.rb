# app/forms/public/payment_form.rb
class Public::PaymentForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :registration_id, :integer
  attribute :payment_method, :string, default: "pix"

  validates :registration_id, presence: true

  def process
    return false unless valid?

    registration = Registration.find(registration_id)
    
    if registration.confirmado?
      errors.add(:base, "Esta inscrição já está paga.")
      return false
    end

    service = StripePaymentService.new(registration)
    @stripe_data = service.create_pix_intent
    true
  rescue StandardError => e
    errors.add(:base, "Erro no gateway de pagamento: #{e.message}")
    false
  end

  attr_reader :stripe_data
end