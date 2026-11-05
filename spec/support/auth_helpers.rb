module AuthHelpers
  def sign_in_as_organizer(organizer, password: "password123")
    post session_path, params: {
      user_type: "organizer",
      email_address: organizer.email_address,
      password: password
    }

    unless response.redirect?
      warn "\n--- FALHA NO LOGIN DO TESTE ---"
      warn "Status: #{response.status}"
      warn "Location: #{response.headers['Location']}"
      warn "Body: #{response.body}"
      warn "Organizer: #{organizer.email_address} / role: #{organizer.role}"
      # warn "Role: #{organizer.role}"
      warn "-------------------------------\n"
    end

    expect(response).to have_http_status(:redirect)
    follow_redirect! 
  end

  def sign_in_as_athlete(athlete, password: "password123")
    post session_path, params: {
      user_type:     "athlete",
      email_address: athlete.email_address,
      password:      password
    }
    # follow_redirect! if response.redirect?
    unless response.redirect?
      warn "\n--- FALHA NO LOGIN DO ATLETA NO TESTE ---"
      warn "Status: #{response.status}"
      warn "Location: #{response.headers['Location']}"
      warn "Body: #{response.body}"
      warn "Athlete: #{athlete.email_address}"
      warn "------------------------------------------\n"
    end

    expect(response).to have_http_status(:redirect)
    follow_redirect!
  end

  # Método para Controller Specs (manipula Current ou session diretamente)
  def sign_in_as_organizer_controller(organizer)
    user_session = create(:session, user: organizer)
    allow(Current).to receive(:session).and_return(user_session)
    allow(Current).to receive(:user).and_return(organizer)
  end

  def sign_out
    delete session_path  # organizer_session_path rescue nil
  end
end