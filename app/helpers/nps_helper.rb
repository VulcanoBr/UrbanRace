module NpsHelper
  def nps_color_class(score)
    if score >= 75
      "text-green-600" # Zona de Excelência
    elsif score >= 50
      "text-blue-600"  # Zona de Qualidade
    elsif score >= 0
      "text-yellow-600" # Zona de Aperfeiçoamento
    else
      "text-red-600"    # Zona Crítica
    end
  end

  def nps_badge_class(nota)
    case nota
    when 9..10 then "bg-green-100 text-green-700 ring-green-600/20"
    when 7..8  then "bg-blue-100 text-blue-700 ring-blue-600/20"
    else            "bg-red-100 text-red-700 ring-red-600/20"
    end
  end
end