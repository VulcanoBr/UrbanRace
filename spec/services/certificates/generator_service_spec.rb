# frozen_string_literal: true

require "rails_helper"

RSpec.describe Certificates::GeneratorService do
  let(:event) { create(:event) }
  let(:athlete) { create(:athlete) }
  let(:registration) { create(:registration, event: event, athlete: athlete) }
  let(:result) { create(:result, :homologado, registration: registration, event: event) }

  describe ".generate" do
    it "cria um certificado e anexa o arquivo PDF" do
      certificate = described_class.generate(result)
      expect(certificate).to be_persisted
      expect(certificate.qr_code_hash).to be_present
      expect(certificate.arquivo_pdf).to be_attached
    end
  end
end
