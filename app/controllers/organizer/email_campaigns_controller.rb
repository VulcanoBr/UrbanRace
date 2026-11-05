# app/controllers/organizer/email_campaigns_controller.rb
class Organizer::EmailCampaignsController < Organizer::BaseController
  before_action :set_event

  def index
    @campaigns = @event.email_campaigns.order(created_at: :desc)
  end

  def new
    @campaign_form = Organizer::EmailCampaignForm.new(event_id: @event.id)
  end

  def create
    @campaign_form = Organizer::EmailCampaignForm.new(campaign_params.merge(event_id: @event.id))
    if @campaign_form.save
      redirect_to organizer_event_email_campaigns_path(@event), notice: "Campanha enfileirada para envio!"
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def set_event
    @event = Current.user.events.find_by!(slug_url: params[:event_id])
  end

  def campaign_params
    params.require(:organizer_email_campaign_form).permit(:assunto, :conteudo, :segmento)
  end
end