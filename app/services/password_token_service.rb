# app/services/password_token_service.rb

class PasswordTokenService
  USER_MODELS = [
    Athlete,
    Organizer
  ].freeze

  USER_TYPES = {
    athlete: Athlete,
    organizer: Organizer,
    operation: Operation
  }.freeze

  USER_CLASSES = [
    Athlete,
    Organizer
  ].freeze

  class << self

    #
    # Gera um token de recuperação
    #
    def generate(user)
      user.generate_token_for(:password_reset)
    end

    #
    # Localiza um usuário pelo token
    #
    def find_user(token)
      USER_MODELS.each do |klass|
        user = klass.find_by_token_for(:password_reset, token)

        return user if user.present?
      end

      nil
    end

    #
    # Token válido?
    #
    def valid?(token)
      find_user(token).present?
    end
  end

end