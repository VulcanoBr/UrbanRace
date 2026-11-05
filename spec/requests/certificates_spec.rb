# frozen_string_literal: true

require "rails_helper"
require "stringio"

RSpec.describe "Validação pública de certificados", type: :request do
  let!(:athlete) do
    create(
      :athlete,
      password: "password123",
      password_confirmation: "password123"
    )
  end

  let!(:registration) do
    create(
      :registration,
      athlete: athlete
    )
  end

  let!(:result) do
    Result.create!(
      registration: registration,
      event: registration.event,
      status_finalizacao: "concluido",
      tempo_liquido: "01:02:03",
      tempo_bruto: "01:02:30",
      posicao_geral: 15,
      posicao_categoria: 4,
      posicao_sexo: 8,
      posicao_faixa_etaria: 3,
      homologado: true,
      homologado_em: Time.current
    )
  end

  def create_generated_certificate(
    result:,
    athlete:,
    qr_code_hash: SecureRandom.hex(16)
  )
    certificate = Certificate.create!(
      result: result,
      athlete: athlete,
      qr_code_hash: qr_code_hash,
      gerado_em: Time.current
    )

    certificate.arquivo_pdf.attach(
      io: StringIO.new("%PDF-1.4\nUrbanRace Test Certificate\n"),
      filename: "certificado_teste.pdf",
      content_type: "application/pdf"
    )

    certificate
  end

  describe "GET /certificates/validate/:qr_code_hash" do
    context "quando o certificado é válido" do
      let!(:certificate) do
        create_generated_certificate(
          result: result,
          athlete: athlete
        )
      end

      it "retorna HTTP 200" do
        get validate_certificate_path(certificate.qr_code_hash)

        expect(response).to have_http_status(:ok)
      end

      it "não exige autenticação" do
        get validate_certificate_path(certificate.qr_code_hash)

        expect(response).not_to redirect_to(new_session_path)
        expect(response).to have_http_status(:ok)
      end

      it "exibe o nome do atleta" do
        get validate_certificate_path(certificate.qr_code_hash)

        expect(response.body).to include(athlete.nome)
      end

      it "exibe o evento" do
        get validate_certificate_path(certificate.qr_code_hash)

        expect(response.body).to include(registration.event.nome)
      end

      it "exibe a distância" do
        get validate_certificate_path(certificate.qr_code_hash)

        expect(response.body).to include(registration.distance.nome)
      end

      it "exibe a categoria" do
        get validate_certificate_path(certificate.qr_code_hash)

        expect(response.body).to include(registration.category.nome)
      end

      it "exibe o resultado" do
        get validate_certificate_path(certificate.qr_code_hash)

        expect(response.body).to include(result.tempo_liquido)
        expect(response.body).to include(result.pace_formatado)
        expect(response.body).to include(result.posicao_geral.to_s)
        expect(response.body).to include(result.posicao_categoria.to_s)
      end

      it "exibe o dorsal" do
        get validate_certificate_path(certificate.qr_code_hash)

        expect(response.body).to include(
          "##{registration.numero_dorsal}"
        )
      end

      it "indica que o certificado é válido" do
        get validate_certificate_path(certificate.qr_code_hash)

        expect(response.body).to include("Certificado válido")
      end

      it "não exibe o CPF do atleta" do
        get validate_certificate_path(certificate.qr_code_hash)

        expect(response.body).not_to include(athlete.cpf)
      end

      it "não exibe o e-mail do atleta" do
        get validate_certificate_path(certificate.qr_code_hash)

        expect(response.body).not_to include(athlete.email_address)
      end

      it "não exibe o telefone do atleta" do
        get validate_certificate_path(certificate.qr_code_hash)

        expect(response.body).not_to include(athlete.telefone.to_s)
      end
    end

    context "quando o hash não existe" do
      it "retorna HTTP 404" do
        get validate_certificate_path("hash-inexistente-123456")

        expect(response).to have_http_status(:not_found)
      end

      it "exibe a página de certificado inválido" do
        get validate_certificate_path("hash-inexistente-123456")

        expect(response.body).to include("Certificado não encontrado")
      end
    end

    context "quando o certificado existe mas o PDF ainda não foi gerado" do
      let!(:certificate) do
        Certificate.create!(
          result: result,
          athlete: athlete,
          qr_code_hash: SecureRandom.hex(16)
        )
      end

      it "não considera o certificado válido" do
        get validate_certificate_path(certificate.qr_code_hash)

        expect(response).to have_http_status(:not_found)
      end

      it "exibe a página de certificado inválido" do
        get validate_certificate_path(certificate.qr_code_hash)

        expect(response.body).to include("Certificado não encontrado")
      end
    end

    context "quando o certificado possui PDF mas o resultado não está homologado" do
      let!(:unapproved_result) do
        Result.create!(
          registration: registration,
          event: registration.event,
          status_finalizacao: "concluido",
          tempo_liquido: "01:02:03",
          tempo_bruto: "01:02:30",
          posicao_geral: 20,
          posicao_categoria: 7,
          posicao_sexo: 10,
          posicao_faixa_etaria: 5,
          homologado: false,
          homologado_em: nil
        )
      end

      let!(:certificate) do
        create_generated_certificate(
          result: unapproved_result,
          athlete: athlete
        )
      end

      it "não considera o certificado válido" do
        get validate_certificate_path(certificate.qr_code_hash)

        expect(response).to have_http_status(:not_found)
      end

      it "não exibe os dados do certificado" do
        get validate_certificate_path(certificate.qr_code_hash)

        expect(response.body).not_to include(athlete.nome)
        expect(response.body).not_to include(
          unapproved_result.tempo_liquido
        )
      end
    end
  end
end