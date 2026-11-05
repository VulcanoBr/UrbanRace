require "rails_helper"

RSpec.describe Photo, type: :model do
  describe "validações" do
    it "aceita foto de atleta" do
      expect(build(:photo, tipo: "atleta")).to be_valid
    end

    it "aceita foto de evento" do
      expect(build(:photo, tipo: "evento")).to be_valid
    end

    it "rejeita tipo desconhecido" do
      photo = build(:photo, tipo: "desconhecido")

      expect(photo).not_to be_valid
    end
  end

  describe "tipo" do
    it "identifica foto de atleta" do
      photo = build(:photo, tipo: "atleta")

      expect(photo).to be_foto_atleta
      expect(photo).not_to be_foto_evento
    end

    it "identifica foto de evento" do
      photo = build(:photo, tipo: "evento")

      expect(photo).to be_foto_evento
      expect(photo).not_to be_foto_atleta
    end
  end

  describe "scopes" do
    it "separa fotos identificadas das pendentes" do
      identificada = create(:photo, reconhecido_ia: true)
      pendente = create(:photo, reconhecido_ia: false)

      expect(described_class.identificadas).to include(identificada)
      expect(described_class.identificadas).not_to include(pendente)

      expect(described_class.pendentes).to include(pendente)
      expect(described_class.pendentes).not_to include(identificada)
    end

    it "filtra fotos por tipo" do
      atleta = create(:photo, tipo: "atleta")
      evento = create(:photo, tipo: "evento")

      expect(described_class.tipo_atleta).to include(atleta)
      expect(described_class.tipo_atleta).not_to include(evento)

      expect(described_class.tipo_evento).to include(evento)
      expect(described_class.tipo_evento).not_to include(atleta)
    end
  end

  describe "#dorsais_detectados" do
    it "retorna os dorsais das inscrições associadas" do
      photo = create(:photo)
      registration = create(:registration, numero_dorsal: 123)

      create(
        :photo_registration,
        photo: photo,
        registration: registration
      )

      expect(photo.dorsais_detectados).to contain_exactly(123)
    end
  end

  describe "#contem_atleta?" do
    it "retorna true quando a inscrição está associada" do
      photo = create(:photo)
      registration = create(:registration)

      create(
        :photo_registration,
        photo: photo,
        registration: registration
      )

      expect(photo.contem_atleta?(registration)).to be(true)
    end

    it "retorna false quando a inscrição não está associada" do
      photo = create(:photo)
      registration = create(:registration)

      expect(photo.contem_atleta?(registration)).to be(false)
    end
  end
end