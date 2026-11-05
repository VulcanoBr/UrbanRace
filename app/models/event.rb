class Event < ApplicationRecord
  belongs_to :organizer

  has_many :distances, dependent: :destroy
  has_many :categories, through: :distances
  has_many :registrations, dependent: :destroy
  has_many :coupons, dependent: :destroy
  has_many :routes, dependent: :destroy
  has_many :supplier_contracts, dependent: :destroy
  has_many :volunteer_stations, dependent: :destroy
  has_many :incidents, dependent: :destroy
  
  has_many :sponsor_contracts, dependent: :destroy
  has_many :licenses, dependent: :destroy
  has_many :nps_responses, dependent: :destroy
  has_many :results, dependent: :destroy
  has_many :broadcast_messages, dependent: :destroy
  has_many :email_campaigns, dependent: :destroy
  has_many :photos, dependent: :destroy

  has_one_attached :banner
  has_one_attached :regulamento
  has_one_attached :kit_image

  enum :status, {
    draft: "draft",
    published: "published",
    active: "active",
    finished: "finished",
    cancelled: "cancelled"
  }, default: :draft



  validates :nome, :data_largada, :slug_url, :cidade, :estado, :local_partida, 
            :horario_largada, :limite_atletas, presence: true
  validates :limite_atletas, numericality: { only_integer: true, greater_than: 0 }
  validates :whatsapp_contato, format: { with: /\A\d+\z/, message: "apenas números" }, allow_blank: true
  validates :slug_url, uniqueness: true, format: { with: /\A[a-z0-9-]+\z/ }
  validates :descricao, length: { maximum: 5000 }

  FINISHABLE_STATUSES  = %w[active published].freeze
  CANCELLABLE_STATUSES = %w[draft published active].freeze

  scope :proximos, -> { where("data_largada >= ?", Date.current).order(data_largada: :asc) }
  scope :operaveis, -> { where("data_largada >= ?", Date.current).order(data_largada: :asc) }
  scope :publicados, -> { where(status: "published") }

  scope :finalizaveis, -> { where(status: FINISHABLE_STATUSES) }
  scope :cancelaveis,  -> { where(status: CANCELLABLE_STATUSES) }

  # ── Transições de status ────────────────────────────────────────────────

  def finishable?
    status.in?(FINISHABLE_STATUSES)
  end
  
  def finish_blockers
    blockers = []

    if data_largada.blank?
      blockers << "A data de largada do evento não está definida."
    elsif data_largada > Date.current
      blockers << "O evento só poderá ser finalizado a partir da data da prova (#{I18n.l(data_largada)})."
    end

    resultados = results

    if resultados.none?
      blockers << "Não existem resultados cadastrados para este evento."
      return blockers
    end

    resultados_homologados = resultados
      .homologados
      .includes(certificate: { arquivo_pdf_attachment: :blob })
      .to_a

    if resultados_homologados.empty?
      blockers << "Nenhum resultado foi homologado. Homologue os resultados antes de finalizar o evento."
      return blockers
    end

    certificados_pendentes = resultados_homologados.count do |result|
      !result.certificate&.gerado?
    end

    if certificados_pendentes.positive?
      blockers << "#{certificados_pendentes} certificado(s) ainda não foi/foram gerado(s) integralmente. Aguarde a geração dos PDFs."
    end

    blockers
  end

  def cancellable?
    status.in?(CANCELLABLE_STATUSES)
  end

  # Finaliza o evento e notifica atletas confirmados.
  def finish!
    unless finishable?
      raise Errors::InvalidTransition,
        "Evento não pode ser finalizado no status '#{status}'."
    end

    blockers = finish_blockers

    if blockers.any?
      raise Errors::InvalidTransition,
        "Não é possível finalizar o evento: #{blockers.join(' ')}"
    end

    transaction do
      update!(status: :finished)
      Events::NotifyFinishJob.perform_later(id)
    end
  end

  def cancellation_blockers
    blockers = []

    if status == "finished"
      blockers << "O evento já foi finalizado e não pode ser cancelado."
    elsif status == "cancelled"
      blockers << "O evento já está cancelado."
    elsif !status.in?(CANCELLABLE_STATUSES)
      blockers << "O evento não pode ser cancelado no status atual: #{status.humanize}."
    end

    if results.exists?
      blockers << "Existem resultados cadastrados para este evento. Remova ou resolva os resultados antes de cancelar."
    end

    if results.joins(:certificate).exists?
      blockers << "Existem certificados associados aos resultados deste evento. O cancelamento não é permitido."
    end

    blockers
  end

  # Cancela o evento, dispara estornos e notifica atletas.
  # reason: motivo opcional exibido no e-mail (ex: "Condições climáticas")
  def cancel!(reason: nil)

    blockers = cancellation_blockers

    if blockers.any?
      raise Errors::InvalidTransition, blockers.join(" ")
    end

    transaction do
      update!(status: :cancelled, cancellation_reason: reason)
      Events::CancelEventJob.perform_later(id)
    end
  end
  
  def sold_out?
    return false if limite_atletas.blank?

    registrations.confirmed.count >= limite_atletas
  end

  def full_address
    "#{local_partida} - #{cidade}/#{estado}"
  end

  def days_until_event
    diff = (data_largada - Date.current).to_i
    diff > 0 ? diff : 0
  end

  def to_param
    slug_url # Isso faz com que public_event_path(event) use o slug em vez do ID
  end
  
end