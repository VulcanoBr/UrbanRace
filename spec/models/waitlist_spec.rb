# frozen_string_literal: true

require "rails_helper"

RSpec.describe Waitlist, type: :model do
  describe "validações" do
    it { is_expected.to validate_inclusion_of(:status).in_array(Waitlist::STATUSES) }
  end

  describe "#notificar_vaga_disponivel!" do
    let(:waitlist) { create(:waitlist, status: "aguardando") }

    it "atualiza status para notificado e envia e-mail" do
      expect {
        waitlist.notificar_vaga_disponivel!
      }.to change { waitlist.status }.from("aguardando").to("notificado")
      .and have_enqueued_mail(WaitlistMailer, :vaga_disponivel)
    end

    it "é idempotente se o status já for notificado" do
      waitlist.update!(status: "notificado")
      expect {
        waitlist.notificar_vaga_disponivel!
      }.not_to change { waitlist.status }
    end
  end

  describe "#expirado_por_prazo?" do
    it "retorna true se notificado há mais de 48h" do
      waitlist = build(:waitlist, status: "notificado", updated_at: 49.hours.ago)
      expect(waitlist).to be_expirado_por_prazo
    end

    it "retorna false se notificado recentemente" do
      waitlist = build(:waitlist, status: "notificado", updated_at: 10.hours.ago)
      expect(waitlist).not_to be_expirado_por_prazo
    end
  end

  describe "#horas_restantes" do
    it "calcula horas restantes para expirar" do
      waitlist = build(:waitlist, status: "notificado", updated_at: 28.hours.ago)
      expect(waitlist.horas_restantes).to eq(20)
    end
  end
end
