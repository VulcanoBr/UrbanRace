# frozen_string_literal: true

# frozen_string_literal: true

require "rails_helper"

RSpec.describe Athletes::PrivacyService, type: :service do
  let(:athlete) { create(:athlete) }

  describe "#anonymize_data!" do
    subject(:service) { described_class.new(athlete) }

    it "anonimiza o nome" do
      original_name = athlete.nome

      service.anonymize_data!

      athlete.reload

      expect(athlete.nome).not_to eq(original_name)
      expect(athlete.nome).to eq("Atleta Anonimizado")
    end

    it "anonimiza o e-mail mantendo-o único" do
      service.anonymize_data!

      reloaded = athlete.reload

      expect(reloaded.email_address).to match(
        /\Adeleted-[a-f0-9]{16}@privacy\.invalid\z/
      )
    end

    it "anonimiza o cpf com valor único" do
      outro_athlete = create(:athlete)

      service.anonymize_data!
      described_class.new(outro_athlete).anonymize_data!

      expect(athlete.reload.cpf).not_to eq(outro_athlete.reload.cpf)
    end

    it "usa o prefixo de anonimização definido pelo serviço" do
      service.anonymize_data!

      expect(athlete.reload.cpf).to start_with(
        Athletes::PrivacyService::ANONIMIZADO_PREFIX
      )
    end

    it "mantém o cpf marcado como anonimizado" do
      service.anonymize_data!

      expect(athlete.reload.anonimizado?).to be true
    end

    it "remove o telefone" do
      service.anonymize_data!

      expect(athlete.reload.telefone).to be_blank
    end

    it "preserva as inscrições do atleta" do
      create(:registration, :confirmado, athlete: athlete)

      expect {
        service.anonymize_data!
      }.not_to change(Registration, :count)
    end

    it "invalida as sessões existentes do atleta" do
      session = create(:session, user: athlete)

      service.anonymize_data!

      expect(Session.exists?(session.id)).to be false
    end

    it "não levanta erro ao ser executado novamente" do
      service.anonymize_data!

      expect {
        service.anonymize_data!
      }.not_to raise_error
    end
  end
end