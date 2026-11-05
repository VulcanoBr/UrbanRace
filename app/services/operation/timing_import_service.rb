# app/services/operation/timing_import_service.rb
#
# Importa um arquivo CSV de tempos de corrida e retorna um relatório
# estruturado com sucessos, avisos e erros.
#
# Formato esperado do CSV:
#   dorsal,waypoint_id,chip_time,gun_time
#   101,3,2026-09-04 08:23:14,2026-09-04 06:00:00
#
# Retorna um OpenStruct com:
#   .importados  (Integer)
#   .atualizados (Integer)
#   .erros       (Array<Hash>) — linhas com problema
#   .avisos      (Array<Hash>) — linhas importadas mas com ressalvas
#   .sucesso?    (Boolean)
require "csv"

module Operation
  class TimingImportService
    COLUNAS_OBRIGATORIAS = %w[dorsal waypoint_id chip_time gun_time].freeze

    Result = Struct.new(:importados, :atualizados, :erros, :avisos, keyword_init: true) do
      def sucesso? = erros.empty?
      def total_processados = importados + atualizados
    end

    def self.import(file, event_id)
      new(file, event_id).import
    end

    def initialize(file, event_id)
      @file     = file
      @event_id = event_id
      @event    = Event.find(event_id)
      @erros    = []
      @avisos   = []
      @importados  = 0
      @atualizados = 0
    end

    def import
      validar_arquivo!
      processar_csv
      Result.new(
        importados:  @importados,
        atualizados: @atualizados,
        erros:       @erros,
        avisos:      @avisos
      )
    rescue CSV::MalformedCSVError => e
      Result.new(
        importados: 0, atualizados: 0, avisos: [],
        erros: [{ linha: "–", dorsal: "–", mensagem: "CSV malformado: #{e.message}" }]
      )
    rescue StandardError => e
      Rails.logger.error "[TimingImportService] #{e.class}: #{e.message}"
      Result.new(
        importados: 0, atualizados: 0, avisos: [],
        erros: [{ linha: "–", dorsal: "–", mensagem: "Erro inesperado: #{e.message}" }]
      )
    end

    private

    def validar_arquivo!
      raise ArgumentError, "Arquivo não informado" unless @file.present?

      extensao = File.extname(@file.original_filename).downcase
      raise ArgumentError, "Apenas arquivos CSV são aceitos (recebido: #{extensao})" unless extensao == ".csv"
    end

    def processar_csv
      @file.rewind

      conteudo = @file.read.force_encoding("UTF-8")
      separador = detectar_separador(conteudo)

      csv = CSV.parse(
        conteudo,
        headers: true,
        header_converters: ->(header) { header.to_s.strip.downcase },
        col_sep: separador
      )

      validar_cabecalho!(csv.headers)

      csv.each.with_index(2) do |row, numero_linha|
        processar_linha(row, numero_linha)
      end
    ensure
      @file.rewind if @file.respond_to?(:rewind)
    end

    # Detecta se o CSV usa vírgula ou ponto e vírgula.
    def detectar_separador(conteudo)
      primeira_linha = conteudo.lines.first.to_s

      if primeira_linha.count(";") > primeira_linha.count(",")
        ";"
      else
        ","
      end
    end

    def validar_cabecalho!(headers)
      faltando = COLUNAS_OBRIGATORIAS - headers.compact.map(&:strip)
      raise ArgumentError, "Colunas obrigatórias ausentes: #{faltando.join(", ")}" if faltando.any?
    end

    def processar_linha(row, numero_linha)
      dorsal = row["dorsal"]&.strip

      # 1. Dorsal obrigatório
      if dorsal.blank?
        @erros << erro(numero_linha, dorsal, "Dorsal em branco")
        return
      end

      # 2. Localizar inscrição no evento
      registration = Registration.find_by(
        event_id: @event_id,
        numero_dorsal: dorsal
      )

      unless registration
        @erros << erro(
          numero_linha,
          dorsal,
          "Inscrição não encontrada para o dorsal #{dorsal} no evento"
        )
        return
      end

      # 3. Somente inscrições checadas podem ter tempos importados.
      # O retorno antecipado impede qualquer criação ou atualização de Timing.
      unless registration.checado?
        @erros << erro(
          numero_linha,
          dorsal,
          "Status da inscrição diferente de 'checado': " \
          "'#{registration.status}'. Tempo não importado."
        )
        return
      end

      # 3. Localizar waypoint
      waypoint = Waypoint.find_by(id: row["waypoint_id"]&.strip)
      unless waypoint
        @erros << erro(numero_linha, dorsal, "Waypoint ID '#{row["waypoint_id"]}' não encontrado")
        return
      end

      # 4. Verificar que waypoint pertence a uma rota do evento
      unless waypoint.route.event_id == @event_id
        @erros << erro(numero_linha, dorsal, "Waypoint #{waypoint.id} não pertence a este evento")
        return
      end

      # 5. Parsear chip_time
      chip_time = parsear_datetime(row["chip_time"]&.strip)
      unless chip_time
        @erros << erro(numero_linha, dorsal, "chip_time inválido: '#{row["chip_time"]}'")
        return
      end

      # 6. Parsear gun_time
      gun_time = parsear_datetime(row["gun_time"]&.strip)
      unless gun_time
        @erros << erro(numero_linha, dorsal, "gun_time inválido: '#{row["gun_time"]}'")
        return
      end

      # 7. Chip time deve ser APÓS gun time
      if chip_time <= gun_time
        @erros << erro(numero_linha, dorsal, "chip_time (#{chip_time}) deve ser posterior ao gun_time (#{gun_time})")
        return
      end

      # 9. Verificar tempo suspeito (> 12h ou < 5 min)
      diferenca_minutos = (chip_time - gun_time) / 60.0
      if diferenca_minutos < 5
        @avisos << aviso(numero_linha, dorsal, "Tempo muito curto: #{diferenca_minutos.round(1)} min — verifique se está correto")
      elsif diferenca_minutos > 720
        @avisos << aviso(numero_linha, dorsal, "Tempo muito longo (> 12h): #{(diferenca_minutos / 60).round(1)} h")
      end

      # 10. Calcular pace
      pace = calcular_pace(chip_time, gun_time, waypoint.km)

      # 11. Criar ou atualizar o Timing (upsert seguro)
      timing = Timing.find_or_initialize_by(
        registration: registration,
        waypoint:     waypoint
      )

      era_novo = timing.new_record?

      timing.assign_attributes(
        chip_time: chip_time,
        gun_time:  gun_time,
        pace_km:   pace
      )

      if timing.save
        era_novo ? @importados += 1 : @atualizados += 1
      else
        @erros << erro(numero_linha, dorsal, "Falha ao salvar: #{timing.errors.full_messages.join("; ")}")
      end
    rescue StandardError => e
      @erros << erro(numero_linha, dorsal, "Erro inesperado na linha: #{e.message}")
    end

    # pace_km armazenado como SEGUNDOS POR KM (decimal)
    def calcular_pace(chip_time, gun_time, km)
      return 0 if km.to_f <= 0

      segundos_totais = (chip_time - gun_time).to_f
      (segundos_totais / km.to_f).round(2)
    end

    def parsear_datetime(valor)
      return nil if valor.blank?
      Time.zone.parse(valor)
    rescue ArgumentError, TypeError
      nil
    end

    def erro(linha, dorsal, mensagem)
      { linha: linha, dorsal: dorsal, mensagem: mensagem }
    end

    def aviso(linha, dorsal, mensagem)
      { linha: linha, dorsal: dorsal, mensagem: mensagem }
    end
  end
end
