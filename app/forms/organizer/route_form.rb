# app/forms/organizer/route_form.rb
class Organizer::RouteForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  attr_reader :route

  attribute :id,               :integer
  attribute :event_id,         :integer
  attribute :distance_id,      :integer
  attribute :geojson_traca,    :string
  attribute :pontos_apoio_json, :string

  # ── Expõe o objeto salvo para o controller usar no redirect ────────────

  validates :event_id,      presence: true
  validates :distance_id,   presence: true
  validates :geojson_traca, presence: true

  validate :distance_belongs_to_event
  validate :valid_geojson
  validate :valid_support_points
  validate :validate_route_structure

  # ── Inicializa a partir de um model Route já existente ─────────────────
  def self.from_model(route)
    new(
      id:               route.id,
      event_id:         route.event_id,
      distance_id:      route.distance_id,
      geojson_traca:    route.geojson_traca.to_json,   # route.geojson_traca.present? ? route.geojson_traca.to_json : "",
      pontos_apoio_json: route.pontos_apoio.present? ? route.pontos_apoio.to_json : "[]"
    )
  end

  def persisted?
    id.present?
  end

  def route
    @route ||= id.present? ? Route.find(id) : Route.new
  end

  # ── Salva e popula @route para o controller usar no redirect ───────────

  def save
    return false unless valid?

    parsed_geojson = parse_json(geojson_traca)
    if parsed_geojson.nil?
      errors.add(:geojson_traca, "não é um JSON válido")
      return false
    end

    @route =
              if id.present?
                Route.find_by!(
                  id: id,
                  event_id: event_id
                )
              else
                Route.new
              end

    @route.assign_attributes(
      event_id: event_id,
      distance_id: distance_id,
      geojson_traca: parsed_geojson,  #JSON.parse(geojson_traca),
      pontos_apoio: parse_json(pontos_apoio_json) || []
       # pontos_apoio_json.present? ?   JSON.parse(pontos_apoio_json) : []
    )

    if @route.save
      true
    else
      promote_errors(@route.errors)
      false
    end

  rescue JSON::ParserError => e
    errors.add(
      :base,
      "Dados do mapa inválidos: #{e.message}"
    )

    false
  end

  def parse_geojson
    JSON.parse(geojson_traca)
  end

  def parse_support_points
    return [] if pontos_apoio_json.blank?

    JSON.parse(pontos_apoio_json)
  end

  private

   def parse_json(value)
    return value if value.is_a?(Hash) || value.is_a?(Array)
    return nil   if value.blank?

    JSON.parse(value)
  rescue JSON::ParserError
    nil
  end

  # ── Validação: distância pertence ao evento ────────────────────────────

  def distance_belongs_to_event
    return if event_id.blank? || distance_id.blank?

    distance = Distance.find_by(id: distance_id)

    unless distance
      errors.add(
        :distance_id,
        "não foi encontrada"
      )

      return
    end

    unless distance.event_id == event_id
      errors.add(
        :distance_id,
        "não pertence ao evento selecionado"
      )
    end
  end

  # ── Validação: GeoJSON válido com LineString de 2+ pontos ─────────────
  def valid_geojson
    return if geojson_traca.blank?

    data = JSON.parse(geojson_traca)

    unless data.is_a?(Hash)
      errors.add(
        :geojson_traca,
        "deve ser um objeto GeoJSON válido"
      )
      return
    end

    # ---------------------------------------------------------
    # GeoJSON Feature
    # ---------------------------------------------------------

    if data["type"] == "Feature"

      geometry = data["geometry"]

      unless geometry.is_a?(Hash)
        errors.add(
          :geojson_traca,
          "deve possuir uma geometria válida"
        )
        return
      end

      unless geometry["type"] == "LineString"
        errors.add(
          :geojson_traca,
          "a geometria deve ser uma LineString"
        )
        return
      end

      coordinates = geometry["coordinates"]

    # ---------------------------------------------------------
    # GeoJSON Geometry
    # ---------------------------------------------------------

    elsif data["type"] == "LineString"

      coordinates = data["coordinates"]

    # ---------------------------------------------------------
    # Formato inválido
    # ---------------------------------------------------------

    else

      errors.add(
        :geojson_traca,
        "deve ser um Feature contendo uma LineString"
      )

      return

    end

    # ---------------------------------------------------------
    # Coordenadas
    # ---------------------------------------------------------

    unless coordinates.is_a?(Array) && coordinates.length >= 2

      errors.add(
        :geojson_traca,
        "o percurso deve possuir pelo menos dois pontos"
      )

      return
    end

    coordinates.each do |coordinate|

      unless coordinate.is_a?(Array) &&
            coordinate.length >= 2 &&
            coordinate[0].present? &&
            coordinate[1].present?

        errors.add(
          :geojson_traca,
          "possui coordenadas inválidas"
        )

        break
      end

    end

  rescue JSON::ParserError
    errors.add(
      :geojson_traca,
      "possui formato JSON inválido"
    )
  end

  # ── Validação: pontos de apoio com lat/lng e tipos válidos ─────────────
  # CORRIGIDO: `tipos` agora é definido antes de ser usado
  def valid_support_points
    return if pontos_apoio_json.blank?

    points = JSON.parse(pontos_apoio_json)

    unless points.is_a?(Array)
      errors.add(
        :pontos_apoio_json,
        "deve ser uma lista de pontos"
      )
      return
    end

    tipos = points.map { |point| point["tipo"] }

    if tipos.count("largada") > 1
      errors.add(
        :pontos_apoio_json,
        "não pode possuir mais de uma largada"
      )
    end

    if tipos.count("chegada") > 1
      errors.add(
        :pontos_apoio_json,
        "não pode possuir mais de uma chegada"
      )
    end

    points.each do |point|

      unless point.is_a?(Hash)
        errors.add(
          :pontos_apoio_json,
          "possui um ponto inválido"
        )
        next
      end

      unless point["latitude"].present? &&
            point["longitude"].present?

        errors.add(
          :pontos_apoio_json,
          "possui ponto sem latitude/longitude"
        )
      end

      unless %w[largada chegada apoio].include?(point["tipo"])

        errors.add(
          :pontos_apoio_json,
          "possui tipo de ponto inválido"
        )
      end

    end

  rescue JSON::ParserError
    errors.add(
      :pontos_apoio_json,
      "possui formato JSON inválido"
    )
  end

  # ── Validação: precisa ter largada e chegada ───────────────────────────
  def validate_route_structure
    return if pontos_apoio_json.blank?

    points = JSON.parse(pontos_apoio_json)

    unless points.is_a?(Array)
      return
    end

    tipos = points.map { |point| point["tipo"] }

    unless tipos.include?("largada")
      errors.add(
        :pontos_apoio_json,
        "é necessário informar a largada"
      )
    end

    unless tipos.include?("chegada")
      errors.add(
        :pontos_apoio_json,
        "é necessário informar a chegada"
      )
    end

  rescue JSON::ParserError
    # valid_support_points já trata esse erro
  end

  def promote_errors(model_errors)
    model_errors.each { |e| errors.add(e.attribute, e.message) }
  end
end
