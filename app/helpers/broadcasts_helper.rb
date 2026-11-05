module BroadcastsHelper
  def broadcast_theme(categoria)
    case categoria
    when "critical", "urgente"
      "bg-red-50 border-red-600 text-red-900"
    when "warning", "alerta"
      "bg-amber-50 border-amber-500 text-amber-900"
    else
      "bg-blue-50 border-blue-600 text-blue-900"
    end
  end

  def broadcast_icon(categoria)
    case categoria
    when "critical", "urgente"
      '<svg class="w-5 h-5 text-red-600" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z" /></svg>'.html_safe
    when "warning", "alerta"
      '<svg class="w-5 h-5 text-amber-600" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4m0 4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z" /></svg>'.html_safe
    else
      '<svg class="w-5 h-5 text-blue-600" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z" /></svg>'.html_safe
    end
  end
end