
# frozen_string_literal: true

require "rails_helper"

RSpec.describe Organizer::ResultHomologatorService do
  let(:result) { create(:result, homologado: false) }

  describe ".call" do
    it "homologa o resultado e agenda a geração do certificado" do
      expect {
        described_class.call(result)
      }.to change { result.reload.homologado? }.from(false).to(true)
       .and change { result.reload.homologado_em }.from(nil)

      expect(Certificates::GenerateSingleJob)
        .to have_been_enqueued
        .with(result.id)
    end

    it "não agenda novamente para um resultado já homologado" do
      result.update!(
        homologado: true,
        homologado_em: 1.day.ago
      )

      expect {
        described_class.call(result)
      }.not_to have_enqueued_job(Certificates::GenerateSingleJob)

      expect(result.reload.homologado_em).to be_within(1.second).of(1.day.ago)
    end
  end
end