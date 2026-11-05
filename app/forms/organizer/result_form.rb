# app/forms/organizer/result_form.rb
#
# Form Object para criação/edição manual de resultados.
# Desacopla a view do model Result, permitindo validações específicas
# do formulário sem poluir o model.
#
class Organizer::ResultForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :id,                  :integer
  attribute :event_id,            :integer
  attribute :registration_id,     :integer
  attribute :posicao_geral,       :integer
  attribute :posicao_categoria,   :integer
  attribute :posicao_sexo,        :integer
  attribute :posicao_faixa_etaria,:integer
  attribute :tempo_bruto,         :string
  attribute :tempo_liquido,       :string
  attribute :status_finalizacao,  :string, default: "concluido"
  attribute :homologado,          :boolean, default: false

  STATUS_OPTIONS = %w[concluido dns dnf dsq].freeze
  TEMPO_REGEX    = /\A\d{2}:\d{2}:\d{2}\z/  # HH:MM:SS

  validates :event_id,           presence: true
  validates :registration_id,    presence: true
  validates :status_finalizacao, presence: true,
                                 inclusion: { in: STATUS_OPTIONS,
                                              message: "deve ser: #{STATUS_OPTIONS.join(", ")}" }

  validates :tempo_liquido, presence: true,
                            format:   { with: TEMPO_REGEX, message: "deve estar no formato HH:MM:SS" },
                            if: -> { status_finalizacao == "concluido" }

  validates :tempo_bruto, format: { with: TEMPO_REGEX, message: "deve estar no formato HH:MM:SS" },
                          allow_blank: true

  validates :posicao_geral, numericality: { only_integer: true, greater_than: 0 },
                            allow_nil: true

  validate :registration_pertence_ao_evento
  validate :tempo_liquido_coerente, if: -> { tempo_liquido.present? && tempo_bruto.present? }

  # Constrói o form a partir de um Result existente
  def self.from_model(result)
    new(
      id:                   result.id,
      event_id:             result.event_id,
      registration_id:      result.registration_id,
      posicao_geral:        result.posicao_geral,
      posicao_categoria:    result.posicao_categoria,
      posicao_sexo:         result.posicao_sexo,
      posicao_faixa_etaria: result.posicao_faixa_etaria,
      tempo_bruto:          result.tempo_bruto,
      tempo_liquido:        result.tempo_liquido,
      status_finalizacao:   result.status_finalizacao,
      homologado:           result.homologado
    )
    
end

  def persisted?
    id.present?
  end

  def save
    return false unless valid?

    became_homologated = false

    ActiveRecord::Base.transaction do
      became_homologated = !result.homologado? && homologado
      persist!
    end

    enqueue_certificate_generation if became_homologated

    true
  rescue ActiveRecord::RecordInvalid => e
    promote_errors(e.record.errors)
    false
  end

  def model_name
    ActiveModel::Name.new(self, nil, "organizer_result_form")
  end

  private

  def result
    @result ||= id.present? ? Result.find(id) : Result.new
  end

  def persist!
    estava_homologado = result.persisted? && result.homologado?

    result.assign_attributes(
      event_id: event_id,
      registration_id: registration_id,
      posicao_geral: posicao_geral,
      posicao_categoria: posicao_categoria,
      posicao_sexo: posicao_sexo,
      posicao_faixa_etaria: posicao_faixa_etaria,
      tempo_bruto: tempo_bruto.presence,
      tempo_liquido: tempo_liquido.presence,
      status_finalizacao: status_finalizacao,
      homologado: homologado
    )

    if homologado && !estava_homologado
      result.homologado_em = Time.current
    elsif !homologado
      result.homologado_em = nil
    end

    result.save!

    @deve_gerar_certificado =
      result.homologado? && !estava_homologado
  end

  def enqueue_certificate_generation
    Certificates::GenerateSingleJob.perform_later(result.id)
  end

  def registration_pertence_ao_evento
    return unless registration_id.present? && event_id.present?

    unless Registration.exists?(id: registration_id, event_id: event_id)
      errors.add(:registration_id, "não pertence a este evento")
    end
  end

  def tempo_liquido_coerente
    liq  = hms_para_segundos(tempo_liquido)
    brut = hms_para_segundos(tempo_bruto)
    return unless liq && brut

    if liq > brut
      errors.add(:tempo_liquido, "não pode ser maior que o tempo bruto")
    end
  end

  def hms_para_segundos(hms)
    return nil unless hms&.match?(TEMPO_REGEX)

    h, m, s = hms.split(":").map(&:to_i)
    h * 3600 + m * 60 + s
  end

  def promote_errors(model_errors)
    model_errors.each { |e| errors.add(e.attribute, e.message) }
  end
end
