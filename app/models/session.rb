class Session < ApplicationRecord
  belongs_to :user, polymorphic: true

  before_create :generate_token 
  
  scope :ativas, -> { where("expires_at > ?", Time.current) } 
  
  private 
  
  def generate_token 
    self.token = SecureRandom.hex(32) 
  end
end
