module EventsHelper
  # Cada string deve conter as classes COMPLETAS para o Tailwind JIT detectar.
  # NUNCA use interpolação do tipo "bg-#{cor}" — o scanner do Tailwind não consegue
  # resolver classes dinâmicas em tempo de build.
  EVENT_STATUS_BADGE = {
    "draft"     => "bg-black      ring-black       text-white font-bold",
    "published" => "bg-blue-500   ring-blue-600    text-white font-bold",
    "active"    => "bg-amber-500 ring-yellow-400  text-white font-bold",
    "finished"  => "bg-green-500  ring-green-600   text-white font-bold",
    "cancelled" => "bg-red-500    ring-red-600     text-white font-bold",
  }.freeze

  def event_status_badge(status)
    EVENT_STATUS_BADGE[status.to_s] || "bg-gray-100 ring-gray-300 text-gray-700 font-medium"
  end

  def event_status_label(status)
    I18n.t("events.statuses.#{status}", default: status.to_s.humanize)
  end
end