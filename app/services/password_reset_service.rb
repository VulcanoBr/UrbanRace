# app/services/password_reset_service.rb

class PasswordResetService

  USER_TYPES = {
    athlete: Athlete,
    organizer: Organizer,
    operation: Operation
  }.freeze

  def self.send_instructions(email_address:, user_type:)
    new(email_address, user_type).send_instructions
  end

  def initialize(email_address, user_type)
    @email_address = email_address.to_s.strip.downcase
    @user_type = user_type.to_s.downcase
  end

  def send_instructions
    return true unless user

    AuthMailer.with(
      user: user,
      token: PasswordTokenService.generate(user)
    ).password_reset.deliver_later

    true
  end

  private

  attr_reader :email_address, :user_type

  def user
    @user ||= begin
      klass = USER_TYPES[user_type.to_sym]

      return nil unless klass

      klass.find_by(email_address: email_address)
    end
  end

end