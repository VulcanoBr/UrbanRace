# app/services/organizer/campaign_target_service.rb
class Organizer::CampaignTargetService
  def initialize(event, segmento)
    @event = event
    @segmento = segmento
  end

  def emails
    case @segmento
    when 'pagos'
      @event.registrations.where(status: :confirmed).joins(:athlete).pluck('athletes.email_address')
    when 'pendentes'
      @event.registrations.where(status: :pending).joins(:athlete).pluck('athletes.email_address')
    when 'espera'
      Waitlist.where(category_id: @event.categories.select(:id)).joins(:athlete).pluck('athletes.email_address')
    else # 'todos'
      # União de inscritos e lista de espera
      ( @event.registrations.joins(:athlete).pluck('athletes.email_address') + 
        Waitlist.where(category_id: @event.categories.select(:id)).joins(:athlete).pluck('athletes.email_address') 
      ).uniq
    end
  end
end