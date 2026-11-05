# app/services/organizer/registration_export_service.rb
require 'csv'

class Organizer::RegistrationExportService
  def initialize(registrations)
    @registrations = registrations
  end

  def to_csv
    CSV.generate(headers: true, col_sep: ";") do |csv|
      csv << ["Dorsal", "Atleta", "CPF", "Categoria", "Tamanho Kit", "Status"]

      @registrations.each do |reg|
        csv << [
          reg.numero_dorsal,
          reg.athlete.nome,
          reg.athlete.cpf,
          reg.category.nome,
          reg.tamanho_kit,
          reg.status.humanize
        ]
      end
    end
  end
end