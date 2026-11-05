class Organizer::BroadcastService
  def self.call(params) # Mudado de .send para .call
    message = BroadcastMessage.new(params)
    message.sent_at = Time.current

    if message.save
      # Transmissão em tempo real via Turbo Streams (Solid Cable)
      Turbo::StreamsChannel.broadcast_prepend_to(
        "event_#{message.event_id}_broadcasts",
        target: "broadcast_alerts_list",
        partial: "organizer/broadcasts/message_card",
        locals: { message: message }
      )
      true
    else
      false
    end
  end
end