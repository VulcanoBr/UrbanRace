class Athletes::PrivacyService
  # Prefixo reconhecível que nunca é um CPF válido
  # (letras garantem que o normalizer não o mutile e que
  # a validação de formato de CPF seja ignorada)
  ANONIMIZADO_PREFIX = "LGPD-DEL-"

  def initialize(athlete)
    @athlete = athlete
  end

  # Direito ao Esquecimento (LGPD art. 18, IV)
  def anonymize_data!
    return if @athlete.anonimizado?

    Athlete.transaction do
      senha_invalida = SecureRandom.hex(32)
      @athlete.update!(
        nome: "Atleta Anonimizado",
        email_address: "deleted-#{SecureRandom.hex(8)}@privacy.invalid",
        cpf: "#{ANONIMIZADO_PREFIX}#{SecureRandom.hex(8)}",
        telefone: nil,
        password: senha_invalida,
        password_confirmation: senha_invalida
      )

      @athlete.sessions.destroy_all
    end
  end

  # Portabilidade (LGPD art. 18, V)
  def export_all_data
    {
      perfil:     @athlete.as_json(only: %i[nome email_address cpf nascimento sexo]),
      inscricoes: @athlete.registrations.includes(:event).map do |r|
        { evento: r.event.nome, data: r.data_inscricao, status: r.status }
      end,
      resultados: @athlete.registrations.joins(:result).map do |r|
        { evento: r.event.nome, tempo: r.result.tempo_liquido, posicao: r.result.posicao_geral }
      end
    }.to_json
  end
end