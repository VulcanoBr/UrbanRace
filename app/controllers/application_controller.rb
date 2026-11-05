# app/controllers/application_controller.rb
class ApplicationController < ActionController::Base
  include Authenticated

  helper_method :current_user, :current_athlete, :current_organizer, :authenticated?

  private

  def current_user
    # O current_user deve ser o usuário da sessão, não os eventos
    Current.user 
  end

  def current_athlete
    Current.user if Current.user.is_a?(Athlete)
  end

  def current_organizer
    user = Current.session&.user
    user if user.is_a?(Organizer)
  end

  def authenticated?
    #Current.user.present?
    Current.session.present?
  end
end