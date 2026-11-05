# app/controllers/pwa_controller.rb
class PwaController < ApplicationController
  allow_unauthenticated_access
  layout false

  def manifest
    # Define ícones e cores para o app mobile do voluntário
  end

  def service_worker
    # Lógica de cache para operação offline
  end
end