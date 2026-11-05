class AuthenticationService
  def initialize(cookies)
    @cookies = cookies
  end

  # Autentica e inicia a sessão
  def login(email_address:, password:, user_class:, request:)
    user = user_class.find_by(email_address: email_address.downcase)
    
    if user&.authenticate(password)
      session = user.sessions.create!(
        ip_address: request.remote_ip,
        user_agent: request.user_agent
      )
      @cookies.signed.permanent[:session_id] = { value: session.id, httponly: true, same_site: :lax }
      return session
    end
    nil
  end

  # Encerra a sessão atual
  def logout
    Session.find_by(id: @cookies.signed[:session_id])&.destroy
    @cookies.delete(:session_id)
  end
end