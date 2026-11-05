# frozen_string_literal: true

require "rails_helper"
require "stringio"

RSpec.describe Certificate, type: :model do
  let!(:athlete) { create(:athlete) }
  let!(:registration) { create(:registration, athlete: athlete) }

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

  def attach_test_pdf(certificate)
    certificate.arquivo_pdf.attach(
      io: StringIO.new("%PDF-1.4\nUrbanRace Test\n"),
      filename: "certificado_teste.pdf",
      content_type: "application/pdf"
    )
  end

  describe "#gerado?" do
    it "retorna false quando não existe PDF" do
      certificate = Certificate.create!(
        result: result,
        athlete: athlete,
        qr_code_hash: SecureRandom.hex(16),
        gerado_em: Time.current
      )

      expect(certificate).not_to be_gerado
    end

    it "retorna false quando não existe gerado_em" do
      certificate = Certificate.create!(
        result: result,
        athlete: athlete,
        qr_code_hash: SecureRandom.hex(16),
        gerado_em: nil
      )

      attach_test_pdf(certificate)

      expect(certificate).not_to be_gerado
    end

    it "retorna true quando existe gerado_em e PDF anexado" do
      certificate = Certificate.create!(
        result: result,
        athlete: athlete,
        qr_code_hash: SecureRandom.hex(16),
        gerado_em: Time.current
      )

      attach_test_pdf(certificate)

      expect(certificate).to be_gerado
    end
  end

  describe "#validavel?" do
    it "retorna true para certificado gerado de resultado homologado" do
      certificate = Certificate.create!(
        result: result,
        athlete: athlete,
        qr_code_hash: SecureRandom.hex(16),
        gerado_em: Time.current
      )

      attach_test_pdf(certificate)

      expect(certificate).to be_validavel
    end

    it "retorna false quando o resultado não está homologado" do
      result.update!(
        homologado: false,
        homologado_em: nil
      )

      certificate = Certificate.create!(
        result: result,
        athlete: athlete,
        qr_code_hash: SecureRandom.hex(16),
        gerado_em: Time.current
      )

      attach_test_pdf(certificate)

      expect(certificate).not_to be_validavel
    end

    it "retorna false quando o certificado ainda não foi gerado" do
      certificate = Certificate.create!(
        result: result,
        athlete: athlete,
        qr_code_hash: SecureRandom.hex(16),
        gerado_em: nil
      )

      expect(certificate).not_to be_validavel
    end
  end
end