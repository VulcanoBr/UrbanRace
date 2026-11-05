class Lot < ApplicationRecord
  belongs_to :distance

  has_many :registrations,
           dependent: :nullify

  enum :status, { ativo: "active",
                  inativo: "inactive",
                  esgotado: "exhausted"
                }

  validates :numero,
            :preco,
            :vagas,
            :abertura,
            :encerramento,
            :status,
            presence: true

  validates :numero,
            numericality: {
              greater_than: 0
            }

  validates :preco,
            numericality: {
              greater_than: 0
            }

  validates :vagas,
            numericality: {
              greater_than: 0
            }

  validate :encerramento_maior_que_abertura

  scope :ordered, -> {
    order(numero: :asc)
  }

  scope :atuais, -> {
    where(
      "abertura <= ? AND encerramento >= ?",
      Time.current,
      Time.current
    ).ativo
  }

  scope :ativos, -> {
    where(status: :active)
  }

  scope :future, -> {
    where("abertura > ?", Time.current)
  }

  scope :past, -> {
    where("encerramento < ?", Time.current)
  }

  before_validation :set_default_status

  def disponivel?
    ativo? && vagas_disponiveis.positive?
  end

  def vagas_ocupadas
    registrations.where( event_id: distance.event_id ).count
  end

  def vagas_disponiveis
    #vagas - vagas_ocupadas
    [vagas - vagas_ocupadas, 0].max
  end

  def percentual_ocupacao
    return 0 if vagas.zero?

    (
      vagas_ocupadas.to_f / vagas * 100
    ).round
  end

  def periodo
    "#{I18n.l(abertura)} até #{I18n.l(encerramento)}"
  end

  def status_badge_color
    case status
    when "active"
      "green"
    when "exhausted"
      "red"
    else
      "gray"
    end
  end

  

  private

  def encerramento_maior_que_abertura
    return if abertura.blank? || encerramento.blank?

    return if encerramento > abertura

    errors.add(
      :encerramento,
      "deve ser maior que a abertura"
    )
  end

  def set_default_status
    self.status ||= "active"
  end
end