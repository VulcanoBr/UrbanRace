class Coupon < ApplicationRecord

  class CouponUnavailableError < StandardError; end
  
  belongs_to :event
  belongs_to :distance, optional: true
  belongs_to :category, optional: true

  enum :tipo, {
    percentual: "percentual",
    fixo: "fixo"
  }

  before_validation :normalize_codigo

  validates :codigo,
            presence: true,
            uniqueness: {
              scope: :event_id,
              case_sensitive: false
            }

  validates :tipo,
            presence: true

  validates :valor,
            presence: true,
            numericality: {
              greater_than: 0
            }

  validates :uso_maximo,
            numericality: {
              only_integer: true,
              greater_than: 0
            },
            allow_nil: true

  validates :uso_atual,
            numericality: {
              only_integer: true,
              greater_than_or_equal_to: 0
            },
            allow_nil: true

  validate :percentual_valido
  validate :uso_atual_nao_pode_ser_maior_que_uso_maximo

  after_initialize :set_defaults

  scope :ativos, -> {
    where(
      "validade IS NULL OR validade >= ?",
      Time.current
    )
  }

  scope :expirados, -> {
    where(
      "validade IS NOT NULL AND validade < ?",
      Time.current
    )
  }

  def valido?
    ativo? &&
      dentro_da_validade? &&
      possui_uso_disponivel?
  end

  def ativo?
    true
  end

  def expirado?
    validade.present? && validade < Time.current
  end

  def dentro_da_validade?
    !expirado?
  end

  def possui_uso_disponivel?
    return true if uso_maximo.blank?

    uso_atual.to_i < uso_maximo
  end

  def esgotado?
    !possui_uso_disponivel?
  end

  def aplicavel_para?(distance: nil, category: nil)
    return false unless valido?

    return false if self.distance.present? &&
                    distance.present? &&
                    self.distance_id != distance.id

    return false if self.distance.present? &&
                    distance.nil?

    return false if self.category.present? &&
                    category.present? &&
                    self.category_id != category.id

    return false if self.category.present? &&
                    category.nil?

    true
  end

  def calcular_desconto(valor_original)
    valor_original = BigDecimal(valor_original.to_s)

    desconto =
      if percentual?
        valor_original * (valor / 100)
      else
        valor
      end

    [desconto, valor_original].min
  end

  def calcular_valor_final(valor_original)
    valor_original = BigDecimal(valor_original.to_s)

    desconto = calcular_desconto(valor_original)

    valor_original - desconto
  end

  def registrar_uso!
    with_lock do
      reload

      raise CouponUnavailableError,
            "Cupom expirado." if expirado?

      unless possui_uso_disponivel?
        raise CouponUnavailableError,
              "Cupom atingiu o limite máximo de utilizações."
      end

      increment!(:uso_atual)
    end
  end

  def status
    return :expirado if expirado?
    return :esgotado if esgotado?

    :disponivel
  end

  private

  def normalize_codigo
    self.codigo = codigo.to_s.strip.upcase
  end

  def set_defaults
    self.uso_atual ||= 0
  end

  def percentual_valido
    return unless percentual?
    return if valor.blank?

    if valor > 100
      errors.add(
        :valor,
        "deve ser menor ou igual a 100 para cupons percentuais"
      )
    end
  end

  def uso_atual_nao_pode_ser_maior_que_uso_maximo
    return if uso_maximo.blank?
    return if uso_atual.blank?

    if uso_atual > uso_maximo
      errors.add(
        :uso_atual,
        "não pode ser maior que o uso máximo"
      )
    end
  end
end