# app/services/operation/kit_delivery_service.rb
module Operation
  class KitDeliveryService
    def self.call(registration, params)
      new(registration, params).call
    end

    def initialize(registration, params)
      @registration = registration
      @params = params
    end

    def call
      return false unless @registration.confirmado?

      final_chip_code = process_chip_code(@params[:chip_code])
      final_bib = @params[:numero_dorsal].presence || @registration.numero_dorsal

      @registration.transaction do
        @registration.update!(
          kit_entregue: true,
          kit_entregue_em: Time.current,
          status: :checado,
          chip_code: final_chip_code,
          numero_dorsal: final_bib
        )
        create_initial_checkin(@registration)
      end

      # Chamamos o mailer FORA da transação. 
      # Assim, se o mailer falhar, o banco já salvou a entrega do kit.
      begin
        Athletes::RegistrationMailer.kit_delivered_confirmation(@registration).deliver_later
      rescue NameError => e
        Rails.logger.error "[Mailer Error] Mailer não encontrado: #{e.message}"
      end

      true
    rescue => e
      Rails.logger.error "[KitDeliveryService Error] #{e.message}"
      false
    end

    private

    def process_chip_code(provided_code)
      if provided_code.present?
        # Limpa espaços e coloca em maiúsculo (Padrão de cronometragem)
        provided_code.strip.upcase
      else
        # Se não informado, gera um código lógico: UR-[ID_EVENTO]-[DORSAL]
        # Isso ajuda se a empresa usar chips descartáveis sem código prévio
        "UR#{@registration.event_id}-#{@params[:numero_dorsal]}"
      end
    end

    def create_initial_checkin(registration)
      # Registra que o atleta "entrou" no sistema através da entrega do kit
      station = registration.event.volunteer_stations.find_by(tipo: "Check-in")
      
      AthleteCheckin.create!(
        registration: registration,
        volunteer_station: station || registration.event.volunteer_stations.first,
        realizado_em: Time.current,
        sincronizado: true
      )
    end
  end
end