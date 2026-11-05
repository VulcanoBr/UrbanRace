module UiHelper

  def metric_card
    " font-semibold text-blue-400 "
  end

  def card_class
    "
      bg-white dark:bg-gray-800
      font-bold
      text-orange-400
      rounded-3xl
      border border-gray-200 dark:border-gray-700
      shadow-sm
      p-6
    "
  end

  def primary_button_class
    "
      inline-flex items-center
      rounded-2xl
      bg-blue-600
      px-5 py-3
      text-sm font-semibold
      text-white
      hover:bg-blue-500
      transition
    "
  end

  def primary_button_full_class
    "
      block w-full
      rounded-2xl
      bg-blue-600
      py-3
      text-center
      text-sm font-semibold
      text-white
      hover:bg-blue-500
      transition
    "
  end

  def secondary_button_class
    "
      inline-flex items-center
      rounded-2xl
      border border-gray-300
      px-4 py-2
      text-sm font-medium
      text-gray-700
      hover:bg-gray-50
    "
  end

  def secondary_button_full_class
    "
      block w-full
      rounded-2xl
      border border-gray-300
      py-3
      text-center
      text-sm font-medium
      text-gray-700
      hover:bg-gray-50
    "
  end

  def sidebar_link_class
    "
      flex items-center
      text-sm
      font-medium
      text-gray-700 dark:text-gray-300
      hover:text-blue-600
      transition
    "
  end

  def input_class
    "
      mt-2
      block
      w-full
      rounded-2xl
      border-gray-300
      shadow-sm
      focus:border-blue-500
      focus:ring-blue-500
      dark:bg-gray-900
      dark:border-gray-700
      dark:text-white
    "
    .squish
  end

  def label_class
    "
      block
      text-sm
      font-semibold
      text-gray-700
      dark:text-gray-300
    "
    .squish
  end

  def table_th_class
    "
      px-8 py-5
      text-left
      text-xs
      font-black
      uppercase
      tracking-wider
      text-gray-500
    "
  end

  def table_td_class
    "
      px-8 py-6
      align-middle
    "
  end

  def event_status_badge(status)
    case status
    when "published"
      "bg-green-50 text-green-700 ring-green-600/20"

    when "active"
      "bg-blue-50 text-blue-700 ring-blue-600/20"

    when "finished"
      "bg-gray-100 text-gray-700 ring-gray-500/20"

    when "cancelled"
      "bg-red-50 text-red-700 ring-red-600/20"

    else
      "bg-yellow-50 text-yellow-700 ring-yellow-600/20"
    end
  end

  def sexo_badge_color(sexo)
    case sexo
    when "masculino"
      "bg-blue-50 text-blue-700"

    when "feminino"
      "bg-pink-50 text-pink-700"

    when "unissex"
      "bg-purple-50 text-purple-700"

    else
      "bg-green-50 text-green-700"
    end
  end

  def lot_status_badge_classes(status)
    case status
    when "active"
      "bg-green-50 text-green-700"

    when "exhausted"
      "bg-red-50 text-red-700"

    else
      "bg-gray-100 text-gray-700"
    end
  end

  def license_status_color(license)
    case license&.status.to_sym
    when :aprovado
      "bg-green-500"
    when :vencido
      "bg-red-600 animate-pulse"
    when :solicitado
      "bg-blue-500"
    else # pendente
      license.prazo_aprovacao < Date.today ? "bg-red-600" : "bg-yellow-500"
    end
  end

  def status_badge_classes(license)
    case license.status.to_sym
    when :aprovado
      "bg-green-50 text-green-700 border-green-200"
    when :vencido
      "bg-red-50 text-red-700 border-red-200"
    when :solicitado
      "bg-blue-50 text-blue-700 border-blue-200"
    else # pendente
      "bg-gray-50 text-gray-700 border-gray-200"
    end
  end

end