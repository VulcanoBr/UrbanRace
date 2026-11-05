# frozen_string_literal: true

require "rails_helper"
require "stringio"

RSpec.describe "Área do atleta - inscrições", type: :request do

  let!(:athlete) do
    create(:athlete)
  end

  let!(:registration) do
    create(
      :registration,
      athlete: athlete
    )
  end

  let!(:result) do
    create(
      :result,
      registration: registration,
      event: registration.event,
      status_finalizacao: "concluido",
      tempo_liquido: "00:45:30",
      tempo_bruto: "00:46:00",
      homologado: true
    )
  end

  before do
    sign_in_as_athlete(athlete)
  end

  describe "GET /athletes/registrations/:id" do

    context "quando o certificado não existe" do
      before do
        Certificate.where(result: result).delete_all
      end

      it "mostra que o certificado ainda não está disponível" do
        expect(result.reload.certificate).to be_nil
        
        get athletes_registration_path(registration)

        expect(response).to have_http_status(:ok)
        expect(response.body).to include("Certificado ainda não disponível")
      end
    end


    context "quando existe certificado mas ainda não foi gerado" do
      let!(:certificate) do
        create(
          :certificate,
          result: result,
          athlete: athlete,
          gerado_em: nil
        )
      end

      it "mostra o certificado como em processamento" do
        get athletes_registration_path(registration)

        expect(response).to have_http_status(:ok)
        expect(response.body).to include("Certificado em processamento")
      end
    end


    context "quando o certificado foi gerado" do
      let!(:certificate) do
        certificate = create(
          :certificate,
          result: result,
          athlete: athlete,
          gerado_em: Time.current
        )

        certificate.arquivo_pdf.attach(
          io: StringIO.new("%PDF-1.4 teste"),
          filename: "certificado.pdf",
          content_type: "application/pdf"
        )

        certificate
      end

      it "mostra o certificado como disponível" do
        get athletes_registration_path(registration)

        expect(response).to have_http_status(:ok)
        expect(response.body).to include("Certificado disponível")
      end
    end


    it "permite visualizar a própria inscrição" do
      get athletes_registration_path(registration)

      expect(response).to have_http_status(:ok)

      expect(response.body).to include(
        registration.event.nome
      )

      expect(response.body).to include(
        registration.athlete.nome
      )

      expect(response.body).to include(
        registration.distance.nome
      )

      expect(response.body).to include(
        registration.category.nome
      )
    end

  end
end