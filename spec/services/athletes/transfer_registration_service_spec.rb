# frozen_string_literal: true

require "rails_helper"

RSpec.describe Athletes::TransferRegistrationService do
  let(:origem)       { create(:athlete) }
  let(:registration) { create(:registration, :confirmado, athlete: origem) }

  describe ".executar_imediato" do
    let(:destino) { create(:athlete) }

    it "transfere a vaga imediatamente para o atleta de destino" do
      # Força a criação de `registration` e `destino` ANTES do expect começar
      # a contar Registration.count. Sem isso, o let lazy avalia `registration`
      # dentro do bloco, contando +1 da criação do setup + +1 da nova inscrição = +2.
      registration
      destino

      expect {
        described_class.executar_imediato(
          registration:     registration,
          atleta_destino:   destino,
          atleta_origem_id: origem.id
        )
      }.to change(Registration, :count).by(1)

      expect(registration.reload.status).to eq("transferido")
    end

    it "levanta TransferError se a inscrição não estiver confirmada" do
      pendente = create(:registration, :pendente, athlete: origem)

      expect {
        described_class.executar_imediato(
          registration:     pendente,
          atleta_destino:   destino,
          atleta_origem_id: origem.id
        )
      }.to raise_error(
        Athletes::TransferRegistrationService::TransferError,
        /não está confirmada/
      )
    end
  end

  describe ".executar_com_convite" do
    it "cria um registro de PendingTransfer com token de expiração" do
      # Força criação antes de contar
      registration

      expect {
        described_class.executar_com_convite(
          registration:     registration,
          email_destino:    "novo_atleta@example.com",
          cpf_destino:      CPF.generate,
          atleta_origem_id: origem.id
        )
      }.to change(PendingTransfer, :count).by(1)
    end
  end
end
