# app/controllers/public/waitlists_controller.rb
class Public::WaitlistsController < ApplicationController
  allow_unauthenticated_access

  def create
    # O Service que criamos anteriormente
    Public::WaitlistService.add_athlete(
      athlete_id: Current.athlete.id, 
      category_id: params[:public_registration_form][:category_id]
    )
    redirect_to area_do_corredor_path, notice: "Você foi adicionado à lista de espera com sucesso!"
  end
end