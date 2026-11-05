# app/mailers/campaign_mailer.rb
class CampaignMailer < ApplicationMailer
  def send_batch(email_address, subject, content)
    @content = content
    mail(to: email_address, subject: subject)
  end
end