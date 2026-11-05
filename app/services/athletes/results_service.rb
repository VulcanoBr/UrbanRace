module Athletes
  class ResultsService

    def initialize(athlete)
      @athlete = athlete
    end

    def call
      {
        resumo: resumo,
        estatisticas: estatisticas,
        resultados: resultados
      }
    end

    private

    attr_reader :athlete

    def estatisticas
      lista = resultados.to_a

      {
        melhor_tempo: melhor_tempo(lista),
        melhor_pace: melhor_pace(lista),
        maior_distancia: maior_distancia(lista),
        podios: podios(lista)
      }
    end

    def resultados
      Result
        .includes(
          :certificate,
          :event,
          registration: [
            :distance,
            :category
          ]
        )
        .joins(:registration)
        .where(registrations: {
          athlete_id: athlete.id
        })
        .order("events.data_largada DESC")
    end

    def resumo
      lista = resultados

      {
        provas: lista.count,
        homologados: lista.homologados.count,
        certificados: lista.count(&:certificate),
        distancia_total: lista.sum {
          |r|
          r.registration.distance.km
        }
      }
    end

    def melhor_tempo(lista)
      return nil if lista.empty?

      lista
        .select(&:homologado?)
        .min_by { |r| tempo_em_segundos(r.tempo_liquido) }
    end

    def melhor_pace(lista)
      return nil if lista.empty?

      lista
        .select { |r| r.pace_medio.present? }
        .min_by { |r| pace_em_segundos(r.pace_medio) }
    end

    def maior_distancia(lista)
      lista
        .map { |r| r.registration.distance.km }
        .max
    end

    def podios(lista)
      lista.count do |r|
        r.posicao_geral.to_i <= 3 ||
          r.posicao_categoria.to_i <= 3
      end
    end

    def tempo_em_segundos(valor)
      return 99_999 unless valor.present?

      h, m, s = valor.split(":").map(&:to_i)

      h * 3600 +
        m * 60 +
        s
    end

    def pace_em_segundos(valor)
      return 99_999 unless valor.present?

      tempo = valor.gsub("/km", "")

      minutos, segundos = tempo.split(":").map(&:to_i)

      minutos * 60 + segundos
    end

  end
end