
# frozen_string_literal: true

require "rails_helper"

RSpec.describe Registration, type: :model do
  # =========================================================
  # CONTEXTO COMPARTILHADO
  # =========================================================

  let(:event) do
    create(
      :event,
      data_largada: Date.new(2026, 11, 13)
    )
  end

  let(:distance) do
    create(
      :distance,
      event: event
    )
  end

  let(:category) do
    create(
      :category,
      distance: distance,
      sexo: "masculino",
      idade_min: 18,
      idade_max: 99
    )
  end

  let(:lot) do
    create(
      :lot,
      distance: distance
    )
  end

  # =========================================================
  # CALLBACKS
  # =========================================================

  describe "callbacks" do
    describe "data_inscricao" do
      it "preenche automaticamente ao criar" do
        registration = build(:registration)

        expect(registration.data_inscricao).to be_nil

        registration.valid?

        expect(registration.data_inscricao).to be_present
      end
    end

    describe "qr_code_hash" do
      it "gera QR Code automaticamente" do
        registration = build(:registration)

        registration.valid?

        expect(registration.qr_code_hash).to be_present
      end
    end
  end

  # =========================================================
  # NORMALIZAÇÃO
  # =========================================================

  describe "normalização" do
    it "normaliza tamanho do kit" do
      registration = build(
        :registration,
        tamanho_kit: "  m "
      )

      registration.valid?

      expect(registration.tamanho_kit).to eq("M")
    end

    it "remove caracteres do telefone" do
      registration = build(
        :registration,
        fone_emergencia: "(21) 99999-9999"
      )

      registration.valid?

      expect(registration.fone_emergencia).to eq("21999999999")
    end
  end

  # =========================================================
  # ELEGIBILIDADE POR SEXO
  # =========================================================

  describe "elegibilidade por sexo" do
    it "não permite atleta feminino em categoria masculina" do
      athlete = create(
        :athlete,
        sexo: "feminino",
        nascimento: 30.years.ago.to_date
      )

      registration = build(
        :registration,
        athlete: athlete,
        event: event,
        distance: distance,
        category: category,
        lot: lot
      )

      expect(registration).not_to be_valid

      expect(registration.errors[:base]).to include(
        a_string_matching(/Sexo incompatível/)
      )
    end
  end

  # =========================================================
  # ELEGIBILIDADE POR IDADE
  # =========================================================

  describe "elegibilidade por idade" do
    it "não permite atleta abaixo da idade mínima" do
      athlete = create(
        :athlete,
        sexo: "masculino",
        nascimento: 16.years.ago.to_date
      )

      registration = build(
        :registration,
        athlete: athlete,
        event: event,
        distance: distance,
        category: category,
        lot: lot
      )

      expect(registration).not_to be_valid

      expect(registration.errors[:base]).to include(
        a_string_matching(/Idade incompatível/)
      )
    end
  end

  # =========================================================
  # INTEGRIDADE DO EVENTO
  # =========================================================

  describe "integridade do evento" do
    it "não permite categoria de outro evento" do
      another_event = create(:event)

      another_distance = create(
        :distance,
        event: another_event
      )

      another_category = create(
        :category,
        distance: another_distance
      )

      registration = build(
        :registration,
        event: event,
        distance: distance,
        category: another_category,
        lot: lot
      )

      expect(registration).not_to be_valid

      expect(registration.errors[:category_id]).to include(
        "não pertence ao evento selecionado"
      )
    end
  end

  describe "dados de emergência" do
    it "exige contato de emergência em uma inscrição normal" do
      registration = build(
        :registration,
        contato_emergencia: nil,
        fone_emergencia: nil
      )

      expect(registration).not_to be_valid

      expect(registration.errors[:contato_emergencia])
        .to include("não pode ficar em branco")

      expect(registration.errors[:fone_emergencia])
        .to include("não pode ficar em branco")
    end

    it "permite dados de emergência vazios no contexto de transferência" do
      registration = build(
        :registration,
        contato_emergencia: nil,
        fone_emergencia: nil
      )

      registration.transferencia = true
      
      expect(registration).to be_valid
    end
  end
end
