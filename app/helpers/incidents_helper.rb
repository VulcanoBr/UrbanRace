module IncidentsHelper
  def severity_bg_color(severity)
    case severity
    when 'low'      then 'bg-green-500'
    when 'medium'   then 'bg-yellow-500'
    when 'high'     then 'bg-orange-600'
    when 'critical' then 'bg-red-600'
    else 'bg-gray-500'
    end
  end

  def severity_color(severity)
    case severity
    when 'low'      then 'bg-green-100 text-green-800'
    when 'medium'   then 'bg-yellow-100 text-yellow-800'
    when 'high'     then 'bg-orange-100 text-orange-800'
    when 'critical' then 'bg-red-100 text-red-800'
    else 'bg-gray-100 text-gray-800'
    end
  end
end