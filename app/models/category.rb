class Category < ApplicationRecord
  belongs_to :distance

  has_many :registrations,
           dependent: :restrict_with_error

  has_many :waitlists,
           dependent: :destroy

  enum :sexo, {
    masculino: "masculino",
    feminino: "feminino",
    unissex: "unissex",
    geral: "geral"
  }

  validates :nome,
            :sexo,
            :idade_min,
            :idade_max,
            presence: true

  validates :idade_min,
            numericality: {
              greater_than_or_equal_to: 0
            }

  validates :idade_max,
            numericality: {
              greater_than: ->(cat) { cat.idade_min.to_i }
            },
            if: -> { idade_min.present? }

  scope :ordered, -> {
    order(:sexo, :idade_min)
  }

  def faixa_etaria
    "#{idade_min} - #{idade_max} anos"
  end

  def registrations_for_event(event)
    registrations.where(event_id: event.id)
  end

  def atleta_elegivel?(athlete, reference_date: nil)
    erros_de_elegibilidade(
      athlete,
      reference_date: reference_date
    ).empty?
  end

  def erros_de_elegibilidade(athlete, reference_date: nil)
    erros = []

    unless athlete.present?
      erros << "Atleta não informado."
      return erros
    end

    if athlete.nascimento.blank?
      erros << "Data de nascimento não informada."
      return erros
    end

    if athlete.nascimento > (reference_date || Date.current)
      erros << "A data de nascimento não pode ser posterior à data da prova."
      return erros
    end

    if athlete.sexo.blank?
      erros << "Sexo não informado."
      return erros
    end

    data_referencia =
     reference_date || Distance.find_by(id: distance_id)&.event&.data_largada&.to_date || Date.current

    idade = calcular_idade(
      athlete.nascimento,
      data_referencia
    )

    unless idade.between?(idade_min, idade_max)
      erros << (
        "Idade incompatível com a categoria. " \
        "A categoria aceita atletas de #{idade_min} a #{idade_max} anos. " \
        "O atleta possui #{idade} anos na data da prova."
      )
    end

    sexo_atleta = normalizar_sexo(athlete.sexo)

    unless %w[unissex geral].include?(sexo.to_s)
      if sexo_atleta != sexo.to_s
        erros << (
          "Sexo incompatível com a categoria. " \
          "A categoria é #{sexo_label(sexo)} e o atleta foi informado como #{sexo_label(sexo_atleta)}."
        )
      end
    end

    erros
  end

  private

  def calcular_idade(data_nascimento, data_referencia)
    data_referencia.year -
      data_nascimento.year -
      (
        data_referencia.month < data_nascimento.month ||
        (
          data_referencia.month == data_nascimento.month &&
          data_referencia.day < data_nascimento.day
        ) ? 1 : 0
      )
  end

  def normalizar_sexo(valor)
    case valor.to_s.strip.downcase
    when "m", "masculino"
      "masculino"
    when "f", "feminino"
      "feminino"
    when "unissex"
      "unissex"
    when "geral"
      "geral"
    else
      valor.to_s.strip.downcase
    end
  end

  def sexo_label(valor)
    {
      "masculino" => "masculino",
      "feminino"  => "feminino",
      "unissex"   => "unissex",
      "geral"     => "geral"
    }[valor.to_s] || valor.to_s
  end
end