# app/controllers/athletes/base_controller.rb
# frozen_string_literal: true

class Athletes::BaseController < ApplicationController
  layout "athlete"

  before_action :require_authentication
  before_action :ensure_athlete_user

  private

  def ensure_athlete_user
    return if Current.user.is_a?(Athlete)

    redirect_to new_session_path,
                alert: "Acesso exclusivo para atletas."
  end
end
