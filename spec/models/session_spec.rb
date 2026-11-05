require "rails_helper"

RSpec.describe Session, type: :model do
  describe "token" do
    it "gera token automaticamente antes da criação" do
      session = create(:session)

      expect(session.token).to be_present
      expect(session.token).to match(/\A[0-9a-f]{64}\z/)
    end

    it "gera tokens diferentes para sessões diferentes" do
      first = create(:session)
      second = create(:session)

      expect(first.token).not_to eq(second.token)
    end
  end

  describe ".ativas" do
    it "retorna sessões ainda válidas" do
      ativa = create(:session, expires_at: 1.hour.from_now)
      expirada = create(:session, expires_at: 1.hour.ago)

      expect(described_class.ativas).to include(ativa)
      expect(described_class.ativas).not_to include(expirada)
    end
  end
end