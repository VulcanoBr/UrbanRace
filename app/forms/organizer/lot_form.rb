class Organizer::LotForm
  include ActiveModel::Model
  include ActiveModel::Attributes
  include ActiveModel::Validations::Callbacks

  attribute :id,          :integer
  attribute :distance_id, :integer
  attribute :numero,      :integer
  attribute :preco,       :string   # mantém :string — normalize_preco cuida da conversão
  attribute :vagas,       :integer
  attribute :abertura,    :datetime
  attribute :encerramento,:datetime
  attribute :status,      :string, default: "active"
  attribute :descricao_kit, :string

  attr_writer :preco_input

  validates :distance_id, :numero, :preco, :vagas,
            :abertura, :encerramento, :status, presence: true
  validates :numero, :vagas, numericality: { greater_than: 0 }
  validates :preco,  numericality: { greater_than: 0 }

  # ✅ CORREÇÃO PRINCIPAL: checar os VALORES do enum, não as chaves
  validates :status, inclusion: {
    in: -> (_) { Lot.statuses.values },
    message: "%{value} não é um status válido"
  }

  validate :encerramento_after_abertura
  validate :validar_limites_de_vagas_da_distancia

  before_validation :normalize_preco

  def persisted? = id.present?

  def self.from_model(lot)
    new(
      id:            lot.id,
      distance_id:   lot.distance_id,
      numero:        lot.numero,
      preco:         lot.preco,
      vagas:         lot.vagas,
      abertura:      lot.abertura,
      encerramento:  lot.encerramento,
      descricao_kit: lot.descricao_kit,
      status:        lot.status
    )
  end

  def save
    return false unless valid?

    lot         = id.present? ? Lot.find(id) : Lot.new
    vagas_antes = lot.persisted? ? lot.vagas : 0

    lot.assign_attributes(
      distance_id:   distance_id,
      numero:        numero,
      preco:         preco,
      vagas:         vagas,
      abertura:      abertura,
      encerramento:  encerramento,
      descricao_kit: descricao_kit,
      status:        status
    )

    ActiveRecord::Base.transaction do
      if lot.save
        self.id = lot.id
        vagas_novas = lot.vagas - vagas_antes

        if vagas_novas > 0 && lot.ativo?
          NotificarListaEsperaJob.perform_later(lot.distance_id, vagas_novas)
        end
        true
      else
        promote_errors(lot.errors)
        raise ActiveRecord::Rollback
      end
    end
  rescue ActiveRecord::Rollback
    false
  rescue => e
    errors.add(:base, "Erro ao salvar: #{e.message}")
    false
  end

  private

  def normalize_preco
    return if preco.blank?
    return unless preco.is_a?(String)

    valor = preco.strip.gsub(/[^\d,.]/, "")
    return if valor.blank?

    if valor.include?(",")
      valor = valor.delete(".")
      valor = valor.sub(",", ".")
    end

    self.preco = valor
  end

  def validar_limites_de_vagas_da_distancia
    return if distance_id.blank? || vagas.blank?

    distancia = Distance.find_by(id: distance_id)
    return errors.add(:distance_id, "não encontrada") unless distancia

    outros_lotes = distancia.lots
    outros_lotes = outros_lotes.where.not(id: id) if id.present?
    soma_outros_lotes = outros_lotes.sum(:vagas)

    total_projetado = soma_outros_lotes + vagas.to_i

    if total_projetado > distancia.vagas_total
      errors.add(
        :vagas,
        "A soma das vagas dos lotes (#{total_projetado}) não pode exceder " \
        "o limite da distância (#{distancia.vagas_total})"
      )
    end

    if id.present?
      vagas_vendidas = Lot.find(id).registrations.count
      if vagas.to_i < vagas_vendidas
        errors.add(
          :vagas,
          "Não é possível reduzir as vagas para menos do que já foi " \
          "vendido (#{vagas_vendidas})"
        )
      end
    end
  end

  def encerramento_after_abertura
    return if abertura.blank? || encerramento.blank?
    errors.add(:encerramento, "deve ser maior que abertura") unless encerramento > abertura
  end

  def promote_errors(model_errors)
    model_errors.each { |e| errors.add(e.attribute, e.message) }
  end
end