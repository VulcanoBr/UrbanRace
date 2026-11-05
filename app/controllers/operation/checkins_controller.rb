# app/controllers/operation/checkins_controller.rb
module Operation
  class CheckinsController < BaseController
    # before_action :set_event

    def index
      @stats = {
        total: @event.registrations.confirmado.count,
        presentes: @event.registrations.where(status: :checked_in).count
      }
      
      if params[:query].present?
        @registrations = @event.registrations.confirmado
                               .joins(:athlete)
                               .where("athletes.nome ILIKE ? OR athletes.cpf LIKE ?", "%#{params[:query]}%", "%#{params[:query]}%")
      end
    end

    def create
      # Lógica de check-in via QR Code ou Botão Manual
      registration = @event.registrations.find_by!(qr_code_hash: params[:qr_code_hash])

      # 2. Identifica o Posto de Trabalho (VolunteerStation)
      # Em uma operação real, você pegaria o ID da estação via params ou session.
      # Aqui buscaremos a primeira estação do tipo 'Check-in' do evento para garantir o save.
      station = @event.volunteer_stations.find_by(tipo: "Check-in") || @event.volunteer_stations.first

      # 3. Alimenta o Form Object
      @checkin_form = Operation::CheckinForm.new(
        registration_id: registration.id,
        volunteer_station_id: station&.id,
        chip_code: params[:chip_code], # Opcional, vindo do leitor ou campo
        offline: false
      )

      if @checkin_form.save
        render json: { 
          success: true, 
          athlete: registration.athlete.nome, 
          dorsal: registration.numero_dorsal,
          kit: registration.tamanho_kit,
          message: "Check-in realizado com sucesso!"
        }
      else
        render json: { 
          success: false, 
          message: @checkin_form.errors.full_messages.to_sentence 
        }, status: :unprocessable_entity
      end
      
    end
  end
end