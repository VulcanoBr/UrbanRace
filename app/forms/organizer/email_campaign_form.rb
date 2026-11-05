# app/forms/organizer/email_campaign_form.rb
class Organizer::EmailCampaignForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :event_id, :integer
  attribute :assunto, :string
  attribute :conteudo, :string
  attribute :segmento, :string # 'todos', 'pagos', 'pendentes', 'espera'

  validates :assunto, :conteudo, :segmento, presence: true

  def save
    return false unless valid?

    campaign = EmailCampaign.create!(
      event_id: event_id,
      assunto: assunto,
      segmento: segmento,
      enviados: 0
    )

    # Dispara o processamento em background via Solid Queue
    SendCampaignJob.perform_later(campaign.id, conteudo)
    true
  end
end