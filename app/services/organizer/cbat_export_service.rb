# app/services/organizer/cbat_export_service.rb
require 'csv'

class Organizer::CbatExportService
  def initialize(event)
    @event = event
    @results = event.results.homologados.includes(registration: [:athlete, :category])
  end

  def generate_csv
    CSV.generate(headers: true, col_sep: ';', encoding: 'UTF-8') do |csv|
      # Cabeçalho padrão CBAT (Simulado)
      csv << ["Registro_CBAT", "Atleta", "CPF", "Sexo", "Nascimento", "Distancia_KM", "Tempo_Bruto", "Tempo_Liquido", "Posicao_Geral", "Posicao_Categoria"]

      @results.each do |res|
        reg = res.registration
        athlete = reg.athlete
        
        csv << [
          "", # Número de registro na federação (se houver no cadastro)
          athlete.nome.upcase,
          athlete.cpf,
          athlete.sexo.upcase,
          athlete.nascimento.strftime("%d/%m/%Y"),
          reg.category.distance.km,
          res.tempo_bruto,
          res.tempo_liquido,
          res.posicao_geral,
          res.posicao_categoria
        ]
      end
    end
  end
end