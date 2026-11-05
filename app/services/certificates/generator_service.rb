# frozen_string_literal: true

require "prawn"
require "stringio"
require "rqrcode"

class Certificates::GeneratorService
  PAGE_WIDTH  = 841.89
  PAGE_HEIGHT = 595.28

  BRAND_BLUE   = "0F4C81"
  BRAND_ORANGE = "F97316"
  BRAND_DARK   = "0F172A"
  BRAND_GRAY   = "64748B"
  LIGHT_GRAY   = "F1F5F9"
  WHITE        = "FFFFFF"

  FONT_REGULAR = Rails.root.join("app/assets/fonts/NotoSans-Regular.ttf").to_s.freeze

  FONT_BOLD = Rails.root.join("app/assets/fonts/NotoSans-Bold.ttf").to_s.freeze

  def self.generate(result)
    new(result).generate
  end

  def initialize(result)
    @result = result
    @registration = result.registration
    @athlete = @registration.athlete
    @event = result.event
  end

  def generate
    prepare_certificate

    pdf = build_pdf

    attach_pdf(pdf)

    @certificate.update!(
      gerado_em: Time.current
    )

    @certificate
  rescue StandardError => e
    log_generation_error(e)
    raise
  end

  private

  def configure_fonts(pdf)
    unless File.exist?(FONT_REGULAR)
      raise "Fonte não encontrada: #{FONT_REGULAR}"
    end

    unless File.exist?(FONT_BOLD)
      raise "Fonte não encontrada: #{FONT_BOLD}"
    end

    pdf.font_families.update(
      "Noto Sans" => {
        normal: FONT_REGULAR,
        bold: FONT_BOLD
      }
    )

    pdf.font("Noto Sans")
  end

  # ============================================================
  # CERTIFICATE
  # ============================================================

  def prepare_certificate
    @certificate =
      Certificate.find_or_initialize_by(result: @result)

    @certificate.athlete = @athlete

    @certificate.qr_code_hash ||=
      SecureRandom.hex(16)
  end

  # ============================================================
  # PDF GENERATION
  # ============================================================

  def build_pdf
    pdf = Prawn::Document.new(
      page_size: "A4",
      page_layout: :landscape,
      margin: [0, 0, 0, 0]
    )

    configure_fonts(pdf)

    draw_background(pdf)
    draw_header(pdf)
    draw_certificate_content(pdf)
    draw_performance(pdf)
    draw_footer(pdf)

    pdf
  end

  # ============================================================
  # BACKGROUND
  # ============================================================

  def draw_background(pdf)
    pdf.canvas do
      # Fundo principal
      pdf.fill_color WHITE

      pdf.fill_rectangle(
        [0, PAGE_HEIGHT],
        PAGE_WIDTH,
        PAGE_HEIGHT
      )

      # Faixa lateral azul
      pdf.fill_color BRAND_BLUE

      pdf.fill_rectangle(
        [0, PAGE_HEIGHT],
        22,
        PAGE_HEIGHT
      )

      # Faixa lateral laranja
      pdf.fill_color BRAND_ORANGE

      pdf.fill_rectangle(
        [22, PAGE_HEIGHT],
        6,
        PAGE_HEIGHT
      )

      # Linha superior
      pdf.fill_color BRAND_BLUE

      pdf.fill_rectangle(
        [0, PAGE_HEIGHT],
        PAGE_WIDTH,
        8
      )
    end
  end

  # ============================================================
  # HEADER
  # ============================================================

  def draw_header(pdf)
    logo_path =
      Rails.root.join(
        "app/assets/images/logo_urbanrace_3d.png"
      )

    if File.exist?(logo_path)
      pdf.image(
        logo_path,
        width: 125,
        at: [358, 570]
      )
    end

    pdf.fill_color BRAND_BLUE

    pdf.font(
      "Noto Sans",
      style: :bold
    )

    pdf.text_box(
      @event.nome.to_s.upcase,
      at: [100, 505],
      width: 640,
      height: 42,
      size: 22,
      align: :center,
      character_spacing: 1
    )

    pdf.fill_color BRAND_ORANGE

    pdf.fill_rectangle(
      [270, 472],
      300,
      3
    )
  end

  # ============================================================
  # MAIN CONTENT
  # ============================================================

  def draw_certificate_content(pdf)

    # CERTIFICADO DE CONCLUSÃO

    pdf.fill_color BRAND_BLUE

    pdf.text_box(
      "CERTIFICADO DE CONCLUSÃO",
      at: [80, 440],
      width: 680,
      height: 30,
      size: 12,
      align: :center,
      style: :bold,
      character_spacing: 2
    )

    # CERTIFICAMOS QUE

    pdf.fill_color BRAND_GRAY

    pdf.text_box(
      "CERTIFICAMOS QUE",
      at: [80, 395],
      width: 680,
      height: 25,
      size: 10,
      align: :center,
      style: :bold,
      character_spacing: 1
    )

    # ATLETA

    athlete_name =
      @athlete.nome.to_s.upcase

    pdf.fill_color BRAND_DARK

    pdf.text_box(
      athlete_name,
      at: [80, 365],
      width: 680,
      height: 60,
      size: athlete_font_size(athlete_name),
      align: :center,
      style: :bold,
      valign: :center
    )

    # DESCRIÇÃO

    pdf.fill_color BRAND_GRAY

    pdf.text_box(
      "concluiu oficialmente a prova de",
      at: [80, 305],
      width: 680,
      height: 25,
      size: 14,
      align: :center
    )

    # DISTÂNCIA

    pdf.fill_color BRAND_ORANGE

    pdf.text_box(
      distance_name,
      at: [80, 265],
      width: 680,
      height: 45,
      size: 26,
      align: :center,
      style: :bold
    )

    # EVENT INFORMATION

    pdf.fill_color BRAND_GRAY

    pdf.text_box(
      event_information,
      at: [80, 225],
      width: 680,
      height: 30,
      size: 10,
      align: :center
    )
  end

  # ============================================================
  # PERFORMANCE
  # ============================================================

  def draw_performance(pdf)

    start_x = 105
    start_y = 190

    box_width = 125
    box_height = 70
    gap = 12

    performance_boxes.each_with_index do |box, index|

      x =
        start_x +
        (index * (box_width + gap))

      # Fundo

      pdf.fill_color LIGHT_GRAY

      pdf.fill_rounded_rectangle(
        [x, start_y],
        box_width,
        box_height,
        8
      )

      # TÍTULO

      pdf.fill_color BRAND_GRAY

      pdf.text_box(
        box[:title],
        at: [x + 10, start_y - 15],
        width: box_width - 20,
        height: 18,
        size: 7,
        align: :center,
        style: :bold
      )

      # VALOR

      pdf.fill_color box[:highlight] ?
        BRAND_BLUE :
        BRAND_DARK

      pdf.text_box(
        box[:value],
        at: [x + 10, start_y - 38],
        width: box_width - 20,
        height: 30,
        size: 16,
        align: :center,
        style: :bold
      )
    end
  end

  # ============================================================
  # FOOTER
  # ============================================================

  def draw_footer(pdf)

    # DORSAL

    pdf.fill_color BRAND_GRAY

    pdf.text_box(
      "DORSAL",
      at: [70, 90],
      width: 100,
      height: 20,
      size: 7,
      style: :bold
    )

    pdf.fill_color BRAND_DARK

    pdf.text_box(
      "##{@registration.numero_dorsal || '-'}",
      at: [70, 70],
      width: 120,
      height: 25,
      size: 16,
      style: :bold
    )

    # CERTIFICADO DIGITAL

    pdf.fill_color BRAND_GRAY

    pdf.text_box(
      "CERTIFICADO DIGITAL",
      at: [250, 90],
      width: 180,
      height: 20,
      size: 7,
      style: :bold,
      align: :center
    )

    pdf.text_box(
      "Documento oficial de participação",
      at: [250, 70],
      width: 180,
      height: 25,
      size: 8,
      align: :center
    )

    # QR CODE

    draw_qr_code(pdf)

    # RODAPÉ

    pdf.fill_color BRAND_GRAY

    pdf.text_box(
      "UrbanRace • Cronometragem Oficial",
      at: [65, 35],
      width: 300,
      height: 20,
      size: 8
    )

    pdf.text_box(
      "Código de autenticação: #{@certificate.qr_code_hash}",
      at: [430, 35],
      width: 320,
      height: 20,
      size: 8,
      align: :right
    )
  end

  # ============================================================
  # QR CODE
  # ============================================================

  def draw_qr_code(pdf)

    validation_url =
      certificate_validation_url

    qr_code =
      RQRCode::QRCode.new(
        validation_url
      )

    modules = qr_code.modules

    module_count = modules.size

    qr_size = 65

    module_size =
      qr_size.to_f /
      module_count

    x = 690
    y = 105

    pdf.fill_color WHITE

    pdf.fill_rectangle(
      [x - 5, y + 5],
      qr_size + 10,
      qr_size + 10
    )

    pdf.fill_color BRAND_DARK

    modules.each_with_index do |row, row_index|

      row.each_with_index do |dark, column_index|

        next unless dark

        pdf.fill_rectangle(
          [
            x + (column_index * module_size),
            y - (row_index * module_size)
          ],
          module_size,
          module_size
        )
      end
    end
  end

  # ============================================================
  # DATA
  # ============================================================

  def distance_name
    @registration.distance&.nome ||
      "PROVA OFICIAL"
  end

  def event_information

    date =
      I18n.l(
        @event.data_largada,
        format: "%d de %B de %Y"
      )

    [
      event_location,
      date,
      @event.data_largada.strftime("%H:%M")
    ].compact.join(" • ")
  end

  def event_location
    return @event.local if @event.respond_to?(:local)

    "RIO DE JANEIRO"
  end

  # ============================================================
  # PERFORMANCE BOXES
  # ============================================================

  def performance_boxes
    [
      {
        title: "TEMPO LÍQUIDO",
        value: @result.tempo_liquido.presence || "-",
        highlight: true
      },

      {
        title: "PACE MÉDIO",
        value: pace_value,
        highlight: false
      },

      {
        title: "CLASS. GERAL",
        value: position_value(
          @result.posicao_geral
        ),
        highlight: false
      },

      {
        title: "CATEGORIA",
        value: position_value(
          @result.posicao_categoria
        ),
        highlight: false
      },

      {
        title: "SEXO",
        value: position_value(
          @result.posicao_sexo
        ),
        highlight: false
      }
    ]
  end

  # ============================================================
  # HELPERS
  # ============================================================

  def position_value(position)
    position.present? ?
      "#{position}º" :
      "-"
  end

  def pace_value
    return "-" if @result.pace_medio.blank?

    "#{@result.pace_medio}/km"
  end

  def athlete_font_size(name)

    case name.length

    when 0..20
      34

    when 21..30
      30

    when 31..40
      26

    else
      22
    end
  end

  # ============================================================
  # VALIDATION URL
  # ============================================================

  def certificate_validation_url

    Rails.application.routes.url_helpers
         .validate_certificate_url(
           @certificate.qr_code_hash,
           host: default_host
         )

  rescue StandardError

    "https://urbanrace.local/certificate/#{@certificate.qr_code_hash}"
  end

  def default_host

    Rails.application.config
         .default_url_options[:host] ||
      "localhost:3000"
  end

  # ============================================================
  # ATTACH PDF
  # ============================================================

  def attach_pdf(pdf)

    filename =
      "certificado_" \
      "#{@event.nome.parameterize}_" \
      "#{@registration.numero_dorsal || @registration.id}.pdf"

    @certificate.arquivo_pdf.attach(
      io: StringIO.new(pdf.render),
      filename: filename,
      content_type: "application/pdf"
    )

    @certificate.save!
  end

  # ============================================================
  # ERROR HANDLING
  # ============================================================

  def log_generation_error(error)
    Rails.logger.error(
      "[Certificates::GeneratorService] " \
      "Falha ao gerar certificado " \
      "result_id=#{@result.id} " \
      "athlete_id=#{@athlete.id} " \
      "error=#{error.class}: #{error.message}"
    )

    return unless error.backtrace

    Rails.logger.error(
      error.backtrace.first(10).join("\n")
    )
  end
end