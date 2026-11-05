module LicensesHelper
  def license_status_classes(status)
    case status
    when 'approved' then 'bg-green-100 text-green-700 border-green-200'
    when 'requested' then 'bg-blue-100 text-blue-700 border-blue-200'
    when 'expired' then 'bg-red-100 text-red-700 border-red-200'
    else 'bg-gray-100 text-gray-700 border-gray-200' # pending
    end
  end
end