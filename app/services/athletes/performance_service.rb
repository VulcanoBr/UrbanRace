# app/services/athletes/performance_service.rb

module Athletes
  class PerformanceService
    def initialize(result)
      @result = result
      @registration = result.registration
      @distance = @registration.distance
      @event = result.event
    end

    def data
      {
        percentual_superado: percentual_superado,
        percentil: percentil,
        velocidade_media: velocidade_media,
        ritmo: ritmo,
        pace: @result.pace_medio,
        estrelas: estrelas,
        progresso: progresso
      }
    end

    private

    attr_reader :result, :registration, :distance, :event

    ############################################################

    def percentual_superado
      total = event.results.homologados.count
      return 0 if total.zero?

      (((total - result.posicao_geral) * 100.0) / total).round
    end

    ############################################################

    def percentil
      100 - percentual_superado
    end

    ############################################################

    def velocidade_media
      return "--" if result.tempo_liquido.blank?

      segundos = tempo_em_segundos(result.tempo_liquido)

      horas = segundos / 3600.0

      km_h = distance.km / horas

      format("%.1f", km_h)
    end

    ############################################################

    def ritmo
      case percentual_superado
      when 90..100
        "Elite"

      when 75..89
        "Excelente"

      when 50..74
        "Muito Bom"

      when 25..49
        "Bom"

      else
        "Concluído"

      end
    end

    ############################################################

    def estrelas
      case percentual_superado
      when 90..100
        5

      when 75..89
        4

      when 50..74
        3

      when 25..49
        2

      else
        1
      end
    end

    ############################################################

    def progresso
      percentual_superado
    end

    ############################################################

    def tempo_em_segundos(texto)
      h, m, s = texto.split(":").map(&:to_i)

      h * 3600 + m * 60 + s
    end
  end
end