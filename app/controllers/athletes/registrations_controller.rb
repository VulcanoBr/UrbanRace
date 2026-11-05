# frozen_string_literal: true

module Athletes
  class RegistrationsController < Athletes::BaseController
    before_action :set_registration, only: %i[show certificate]

    def show
      @result = @registration.result
      @certificate = @result&.certificate
    end

    def certificate
      @result = @registration.result
      @certificate = @result&.certificate

      if @certificate&.gerado? && @result&.certificado_geravel?
        send_data @certificate.arquivo_pdf.download,
                  filename: "Certificado_#{@registration.event.nome.parameterize}.pdf",
                  type: "application/pdf",
                  disposition: "inline"
      else
        redirect_to athletes_registration_path(@registration),
                    alert: "Seu certificado ainda não está disponível para download."
      end
    end

    private

    def set_registration
      @registration = Current.user.registrations
                              .includes(
                                :event,
                                :distance,
                                :category,
                                :lot,
                                result: :certificate
                              )
                              .find(params[:id])
    rescue ActiveRecord::RecordNotFound
      redirect_to athletes_root_path,
                  alert: "Inscrição não encontrada."
    end
  end
end