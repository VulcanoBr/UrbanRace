class Distance < ApplicationRecord
  belongs_to :event

  has_many :categories, dependent: :destroy

  has_many :lots,
           dependent: :destroy

  has_many :routes, dependent: :destroy

  validates :nome,
            :km,
            :vagas_total,
            presence: true

  validates :km,
            numericality: {
              greater_than: 0
            }

  validates :vagas_total,
            numericality: {
              greater_than: 0
            }

  validates :nome,
            uniqueness: {
              scope: :event_id,
              message: "já cadastrada neste evento"
            }
  validates :vagas_ocupadas,
            numericality: {
              greater_than_or_equal_to: 0
            }

  before_validation :set_default_vagas

  scope :with_availability, -> { where("vagas_ocupadas < vagas_total") }

  scope :ordered, -> { order(km: :asc) }

  scope :with_relations, -> { includes(:categories, :lots) }

  def vagas_ocupadas
    super || 0
  end

  def vagas_disponiveis
    vagas_total - vagas_ocupadas
  end

  def sold_out?
    vagas_disponiveis <= 0
  end

  def percentual_ocupacao
    return 0 if vagas_total.zero?

    ((vagas_ocupadas.to_f / vagas_total) * 100).round
  end

  def current_lot
    lots.atuais.first
  end

  def esgotada?
    vagas_disponiveis <= 0
  end

  def menor_preco
    lots.minimum(:preco)
  end

  private

  def set_default_vagas
    self.vagas_ocupadas ||= 0
  end
end