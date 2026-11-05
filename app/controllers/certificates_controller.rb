# frozen_string_literal: true

class CertificatesController < ApplicationController
  allow_unauthenticated_access

  def validate
    @certificate = Certificate.find_by(
      qr_code_hash: params[:qr_code_hash]
    )

    unless certificado_valido?
      render :invalid, status: :not_found
      return
    end

    @result = @certificate.result
    @registration = @result.registration
    @athlete = @certificate.athlete
    @event = @result.event
  end

  private

  def certificado_valido?
    return false unless @certificate
    return false unless @certificate.gerado?
    return false unless @certificate.result
    return false unless @certificate.result.homologado?

    true
  end
end