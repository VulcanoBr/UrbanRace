# app/services/operation/result_calculator_service.rb
#
# Converte os Timings de chegada de um evento em Results.
# Calcula: tempo_liquido, tempo_bruto, pace_medio, posicao_geral,
#          posicao_categoria, posicao_sexo, posicao_faixa_etaria.
#
# Uso:
#   relatorio = Operation::ResultCalculatorService.calculate(@event)
#   relatorio.gerados     # => 120
#   relatorio.erros       # => [{ dorsal: "5", mensagem: "..." }]
#
module Operation
  class ResultCalculatorService
    RelatorioResult = Struct.new(:gerados, :atualizados, :erros, keyword_init: true) do
      def sucesso? = erros.empty?
      def total = gerados + atualizados
    end

    def self.calculate(event)
      new(event).calculate
    end

    def initialize(event)
      @event    = event
      @erros    = []
      @gerados  = 0
      @atualizados = 0
    end

    def calculate
      # 1. Buscar waypoints de chegada deste evento
      waypoints_chegada = Waypoint
        .joins(:route)
        .where(routes: { event_id: @event.id }, eh_chegada: true)

      if waypoints_chegada.empty?
        return RelatorioResult.new(
          gerados: 0, atualizados: 0,
          erros: [{ dorsal: "–", mensagem: "Nenhum waypoint de chegada encontrado para este evento." }]
        )
      end

      # 2. Buscar todos os timings de chegada do evento
      timings_chegada = Timing
        .joins(:waypoint, registration: :event)
        .where(waypoints: { eh_chegada: true })
        .where(events: { id: @event.id })
        .where(registrations: { event_id: @event.id })
        .includes(registration: [:athlete, :distance, :category])
        .order(:chip_time)

      if timings_chegada.empty?
        return RelatorioResult.new(
          gerados: 0, atualizados: 0,
          erros: [{ dorsal: "–", mensagem: "Nenhum tempo de chegada importado ainda." }]
        )
      end

      # 3. Processar cada timing
      ActiveRecord::Base.transaction do
        timings_chegada.each do |timing|
          processar_timing(timing)
        end

        # 4. Recalcular posições após criar/atualizar todos os results
        recalcular_posicoes
      end

      RelatorioResult.new(
        gerados:    @gerados,
        atualizados: @atualizados,
        erros:      @erros
      )
    rescue StandardError => e
      Rails.logger.error "[ResultCalculatorService] #{e.class}: #{e.message}\n#{e.backtrace.first(5).join("\n")}"
      RelatorioResult.new(
        gerados: 0, atualizados: 0,
        erros: [{ dorsal: "–", mensagem: "Erro ao calcular resultados: #{e.message}" }]
      )
    end

    private

    def processar_timing(timing)
      registration = timing.registration
      dorsal       = registration.numero_dorsal

      # Calcular tempo líquido e bruto em HH:MM:SS
      segundos_liquido = (timing.chip_time - timing.gun_time).to_i
      segundos_bruto   = calcular_tempo_bruto(timing)

      tempo_liquido = segundos_para_hms(segundos_liquido)
      tempo_bruto   = segundos_bruto ? segundos_para_hms(segundos_bruto) : tempo_liquido

      # Converter pace_km (segundos/km decimal) → "MM:SS /km"
      pace_medio = pace_decimal_para_string(timing.pace_km)

      # Upsert do Result
      result = Result.find_or_initialize_by(
        registration_id: registration.id,
        event_id:        @event.id
      )

      era_novo = result.new_record?

      result.assign_attributes(
        tempo_liquido:      tempo_liquido,
        tempo_bruto:        tempo_bruto,
        pace_medio:         pace_medio,
        status_finalizacao: "concluido",
        # Posições serão calculadas depois em recalcular_posicoes
        posicao_geral:      nil,
        posicao_categoria:  nil,
        posicao_sexo:       nil,
        posicao_faixa_etaria: nil,
        #homologado:         false
      )

      if result.save
        era_novo ? @gerados += 1 : @atualizados += 1
      else
        @erros << {
          dorsal:    dorsal,
          mensagem: "Falha ao salvar result: #{result.errors.full_messages.join("; ")}"
        }
      end
    rescue StandardError => e
      @erros << { dorsal: dorsal.to_s, mensagem: e.message }
    end

    # Calcula posicao_geral, posicao_categoria, posicao_sexo, posicao_faixa_etaria
    # Ordena por tempo_liquido para cada agrupamento
    def recalcular_posicoes
      results = @event.results
                      .where(status_finalizacao: "concluido")
                      .includes(registration: [:athlete, :category, :distance])
                      .order(:tempo_liquido)

      # Posição geral (todos os finishers do evento, ordenados por tempo líquido)
      results.each_with_index do |result, idx|
        result.update_columns(posicao_geral: idx + 1)
      end

      # Posição por sexo
      %w[masculino feminino].each do |sexo|
        results_sexo = results.select { |r| r.registration.athlete.sexo == sexo }
        results_sexo.each_with_index do |result, idx|
          result.update_columns(posicao_sexo: idx + 1)
        end
      end

      # Posição por categoria
      category_ids = results.map { |r| r.registration.category_id }.uniq.compact
      category_ids.each do |cat_id|
        results_cat = results.select { |r| r.registration.category_id == cat_id }
        results_cat.each_with_index do |result, idx|
          result.update_columns(posicao_categoria: idx + 1)
        end
      end

      # Posição por faixa etária (agrupado por distância + faixa de 5 anos)
      results_com_nasc = results.select { |r| r.registration.athlete.nascimento.present? }

      por_distancia_e_faixa = results_com_nasc.group_by do |result|
        athlete = result.registration.athlete

        idade = calcular_idade(
          athlete.nascimento,
          @event.data_largada
        )

        faixa = (idade / 5) * 5

        [
          result.registration.distance_id,
          athlete.sexo,
          faixa
        ]
      end

      por_distancia_e_faixa.each do |_chave, lista|
        lista.each_with_index do |result, idx|
          result.update_columns(posicao_faixa_etaria: idx + 1)
        end
      end
    end

    # Busca o gun_time da largada oficial do evento (primeiro waypoint de largada)
    # Se não encontrar, usa o gun_time do próprio timing
    def calcular_tempo_bruto(timing)
      largada = Timing
        .joins(:waypoint, registration: :event)
        .where(waypoints: { eh_largada: true }, events: { id: @event.id })
        .where(registration_id: timing.registration_id)
        .first

      return nil unless largada&.gun_time && timing.chip_time
      (timing.chip_time - largada.gun_time).to_i
    end

    # pace_km é DECIMAL (segundos por km)
    def pace_decimal_para_string(pace_km_segundos)
      return nil if pace_km_segundos.nil? || pace_km_segundos.to_f <= 0

      total_segundos = pace_km_segundos.to_f
      minutos = (total_segundos / 60).to_i
      segundos = (total_segundos % 60).to_i
      format("%02d:%02d", minutos, segundos)
    end

    def segundos_para_hms(total_segundos)
      return nil if total_segundos.nil? || total_segundos < 0

      horas    = total_segundos / 3600
      minutos  = (total_segundos % 3600) / 60
      segundos = total_segundos % 60
      format("%02d:%02d:%02d", horas, minutos, segundos)
    end

    def calcular_idade(data_nascimento, data_referencia)
      anos = data_referencia.year - data_nascimento.year
      aniversario_passou = (data_referencia.month > data_nascimento.month) ||
                           (data_referencia.month == data_nascimento.month &&
                            data_referencia.day >= data_nascimento.day)
      aniversario_passou ? anos : anos - 1
    end
  end
end
