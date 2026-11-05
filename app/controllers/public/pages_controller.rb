class Public::PagesController < ApplicationController
  allow_unauthenticated_access only: [ :sobre, :privacidade, :lgpd ]
  def sobre; end

  def privacidade; end

  def lgpd; end

end
