# db/seeds.rb
require "faker"

Faker::Config.default_locale = "pt-BR"
Faker::UniqueGenerator.clear

puts "--- Iniciando Seeds UrbanRace Completo (V4.1) ---"

# 1. Limpeza Total do Banco de Dados (Ordem inversa para evitar erros de FK)
puts "Limpando banco de dados..."
models = [
  PendingTransfer, NpsResponse, Certificate, Result, Timing, AthleteCheckin, Incident, PhotoRegistration, Photo, 
  Session, Waitlist, Transfer, Payment, Registration, BroadcastMessage,
  VolunteerShift, VolunteerStation, Volunteer, 
  License, Waypoint, Route, SupplierDelivery, SupplierContract, Supplier,
  Category, Lot, Distance, Coupon, SponsorContract, Sponsor, EmailCampaign, 
  Event, Athlete, Organizer
]
models.each { |m| m.delete_all if ActiveRecord::Base.connection.table_exists?(m.table_name) }

# 2. Organizador (Administrador do Sistema)
admin = Organizer.create!(
  name: "Administrador UrbanRace",
  email_address: "admin@urbanrace.com",
  password: "password123",
  password_confirmation: "password123",
  role: "admin"
)

# Criando um Staff (Operation)
Organizer.create!(
  name: "Guilhermina Operacional",
  email_address: "staff@urbanrace.com",
  password: "password123",
  password_confirmation: "password123",
  role: "staff"
)

# 3. Base de Atletas (199 atletas)
puts "Gerando 199 atletas..."

atletas_globais = 199.times.map do |i|
  sexo = i.even? ? "masculino" : "feminino"
  # Pegamos apenas o primeiro nome para o e-mail
  primeiro_nome = (sexo == "masculino" ? Faker::Name.male_first_name : Faker::Name.female_first_name)
  sobrenome = Faker::Name.last_name
  nome_completo = "#{primeiro_nome} #{sobrenome}"

  Athlete.create!(
    nome: nome_completo,
    # E-mail curto e garantido: nome + indice
    # .parameterize remove acentos e espaços
    email_address: "#{primeiro_nome.parameterize}#{i}@email.com",
    
    cpf: Faker::IdNumber.brazilian_citizen_number(formatted: true),
    nascimento: Faker::Date.birthday(min_age: 19, max_age: 66),
    sexo: sexo,
    telefone: Faker::PhoneNumber.cell_phone,
    password: "password123"
  )
end

# 4. EVENTO ATUAL (Futuro) - Meia Maratona 2026
puts "Configurando Evento Futuro..."
event_futuro = Event.create!(
  nome: "Meia Maratona de Verão 2026",
  data_largada: 3.months.from_now,
  slug_url: "meia-maratona-verao-2026",
  status: "published", cidade: "Rio de Janeiro", estado: "RJ",
  local_partida: "Aterro do Flamengo", horario_largada: "07:00",
  organizer: admin, limite_atletas: 1200, whatsapp_contato: "21945452300",
  descricao: "Meia Maratona de Verão 2026
<br>
A Meia Maratona de Verão 2026 será um grande evento esportivo realizado no Aterro do Flamengo, no Rio de Janeiro, reunindo corredores de diferentes níveis de experiência em uma celebração de esporte, saúde, superação e qualidade de vida.<br>
A competição contará com duas opções de percurso: 5 km e 21 km, permitindo a participação tanto de atletas que buscam uma prova mais curta e dinâmica quanto de corredores preparados para o desafio da meia maratona.<br>
A largada está programada para o dia 13 de novembro de 2026, às 7h, em um dos cenários mais tradicionais e emblemáticos do Rio de Janeiro. O percurso proporcionará aos participantes uma experiência esportiva marcada pela beleza da orla carioca e pela atmosfera característica dos grandes eventos de corrida de rua.<br>
A prova será destinada a participantes de todos os sexos, com idade mínima de 18 anos, respeitando as categorias e condições previstas no regulamento oficial do evento.
<br>

🏃 Percursos
5 km — ideal para corredores iniciantes, praticantes de atividade física e atletas que desejam uma prova rápida e desafiadora.
21 km — destinada aos corredores que desejam enfrentar o desafio completo de uma meia maratona, combinando resistência, estratégia e superação.
<br>
📍 Informações principais

Evento: Meia Maratona de Verão 2026
Local: Aterro do Flamengo — Rio de Janeiro/RJ
Data: 13 de novembro de 2026
Horário da largada: 7h00
Percursos: 5 km e 21 km
Idade mínima: 18 anos
Participação: Todos os sexos

<br>
A Meia Maratona de Verão 2026 foi pensada para proporcionar uma experiência completa aos participantes, valorizando não apenas o desempenho esportivo, mas também a integração, o bem-estar e o espírito de superação que fazem da corrida de rua uma das modalidades esportivas mais populares do país.
<br>
Prepare-se para correr, superar seus limites e viver a energia do Rio de Janeiro. A linha de largada espera por você!",
  kit_descricao: "🎽 Kit do Atleta — Meia Maratona de Verão 2026
<br>

📦 O kit inclui
<li>Camiseta oficial do evento — modelo exclusivo da Meia Maratona de Verão 2026, confeccionada em tecido leve e confortável, ideal para a prática esportiva.</li>
<li>Número de peito personalizado — identificação oficial do atleta durante a prova, contendo numeração exclusiva e espaço para identificação.</li>
<li>Chip de cronometragem — dispositivo utilizado para registrar o tempo e o desempenho do participante durante o percurso.</li>
<li>Medalha de participação 🏅 — entregue aos atletas que concluírem o percurso, como reconhecimento pela participação e superação.</li>
<li>Sacola ou mochila oficial do evento — prática para transporte dos itens pessoais e dos materiais fornecidos no kit.</li>
<li>Brindes dos patrocinadores e parceiros — itens promocionais e experiências disponibilizadas de acordo com as ações e parcerias confirmadas para o evento.</li>
",
  cronograma: "🗓️ Cronograma Oficial — Meia Maratona de Verão 2026 <br>
Horário /	Atividade /	Descrição
05h00 - Abertura da arena - Abertura da área do evento, acesso dos atletas e início da operação das equipes.
05h15 - Abertura dos serviços ao atleta - Funcionamento dos pontos de informação, guarda-volumes, banheiros e demais serviços.
05h30 - Aquecimento e preparação - Início das atividades de aquecimento e preparação dos participantes.
06h00 - Acesso às áreas de largada - Organização dos atletas por percurso e direcionamento para os setores de largada.
06h30 - Concentração dos atletas - Formação dos corredores e orientações finais da organização.
06h45 - Briefing final - Avisos de segurança, informações sobre o percurso e orientações para a largada.
06h55 - Chamada para largada - Atletas posicionados nos respectivos setores.
07h00 - 🏁 LARGADA OFICIAL - Início oficial da Meia Maratona de Verão 2026.
07h15 - Operação dos pontos de apoio	- Postos de hidratação e suporte funcionando ao longo dos percursos.
07h30 - Primeiras chegadas — 5 km - Previsão de chegada dos primeiros participantes do percurso de 5 km.
08h00 - Cerimônia de chegada - Recepção dos atletas, entrega de medalhas e suporte aos participantes.
08h30 - Primeiras chegadas — 21 km - Previsão de chegada dos primeiros participantes da meia maratona.
09h00 - Premiação - Reconhecimento dos atletas classificados nas categorias previstas no regulamento.
10h30 - Encerramento da chegada	 - Finalização progressiva do atendimento aos atletas e da estrutura de chegada.
11h00 - Encerramento do evento - Encerramento das atividades oficiais e início da desmontagem da estrutura."
)

# Distâncias, Categorias e Lotes do Evento Futuro
[ {n: "5K", k: 5.0}, {n: "21K", k: 21.1} ].each do |d_info|
  dist = Distance.create!(event: event_futuro, nome: d_info[:n], km: d_info[:k], vagas_total: 600)
  
  categories_data = [
    { nome: "masculino 18-39", sexo: "masculino", idade_min: 18, idade_max: 39 },
    { nome: "feminino 18-39", sexo: "feminino", idade_min: 18, idade_max: 39 },
    { nome: "masculino 40+", sexo: "masculino", idade_min: 40, idade_max: 99 },
    { nome: "feminino 40+", sexo: "feminino", idade_min: 40, idade_max: 99 }
  ]

  categories_data.each do |category_data|
    Category.create!(
      distance: dist,
      nome: category_data[:nome],
      sexo: category_data[:sexo],
      idade_min: category_data[:idade_min],
      idade_max: category_data[:idade_max]
    )
  end
  
  Lot.create!(distance: dist, numero: 1, preco: 95.00, vagas: 500, abertura: 1.month.ago, encerramento: 1.month.from_now, status: "ativo")

  # Mapear Rota do Evento Futuro
  r = Route.create!(event: event_futuro, distance: dist, geojson_traca: { type: "LineString", coordinates: [[-43.21, -22.95], [-43.22, -22.96]] })
  Waypoint.create!(route: r, nome: "Largada #{d_info[:n]}", km: 0.0, eh_largada: true)
  Waypoint.create!(route: r, nome: "Chegada #{d_info[:n]}", km: d_info[:k], eh_chegada: true)
end

def idade_na_data(nascimento, data_referencia)
  idade = data_referencia.year - nascimento.year

  if data_referencia.month < nascimento.month ||
     (
       data_referencia.month == nascimento.month &&
       data_referencia.day < nascimento.day
     )
    idade -= 1
  end

  idade
end

# Simular 100 inscrições no evento futuro
puts "Inscrevendo atletas no evento futuro..."

atletas_globais.sample(100).each_with_index do |atleta, idx|

  dist = event_futuro.distances.sample

  # -------------------------------------------------------
  # CALCULAR IDADE DO ATLETA NA DATA DO EVENTO
  # -------------------------------------------------------

  idade = idade_na_data(
    atleta.nascimento,
    event_futuro.data_largada.to_date
  )

  # -------------------------------------------------------
  # CONVERTER SEXO DO ATLETA PARA SEXO DA CATEGORIA
  # -------------------------------------------------------

  sexo_categoria =
    atleta.sexo == "masculino" ? "masculino" : "feminino"

  # -------------------------------------------------------
  # BUSCAR CATEGORIA COMPATÍVEL
  # -------------------------------------------------------

  categoria = dist.categories
                .where(sexo: sexo_categoria)
                .where("idade_min <= ?", idade)
                .where("idade_max >= ?", idade)
                .first

  # -------------------------------------------------------
  # VALIDAÇÃO DE SEGURANÇA
  # -------------------------------------------------------

  unless categoria
    puts "⚠️ Categoria não encontrada para:"
    puts "Atleta: #{atleta.nome}"
    puts "Sexo: #{atleta.sexo}"
    puts "Idade: #{idade}"

    next
  end

  # -------------------------------------------------------
  # CRIAR INSCRIÇÃO
  # -------------------------------------------------------

  reg = Registration.create!(
    athlete: atleta,
    event: event_futuro,
    distance: dist,
    category: categoria,
    lot: dist.lots.first,
    status: "checked_in",
    numero_dorsal: 1000 + idx,
    aceite_lgpd: true,
    contato_emergencia: Faker::Name.name,
    fone_emergencia: Faker::PhoneNumber.cell_phone,
    data_inscricao: Time.current,
    tamanho_kit: "M"
  )

  # -------------------------------------------------------
  # PAGAMENTO
  # -------------------------------------------------------

  Payment.create!(
    registration: reg,
    metodo: "pix",
    valor: 95.0,
    status: "pago",
    pago_em: Time.current
  )

  # -------------------------------------------------------
  # ATUALIZAR VAGAS
  # -------------------------------------------------------

  Distance.increment_counter( :vagas_ocupadas, dist.id )
end

# 6. Fornecedores e Contratos
puts "Criando Fornecedores e Contratos..."
servicos = [ "Cronometragem", "Segurança", "Atendimento Médico e Ambulância", "Troféus e Medalhas",
      "Camisetas", "Kits do Atleta", "Número de Peito", "Chip de Cronometragem", "Hidratação", "Alimentação",
      "Palco e Sonorização", "Iluminação", "Banheiros Químicos", "Tendas", "Gradis e Isolamento", "Sinalização",
      "Fotografia", "Filmagem", "Marketing e Publicidade", "Limpeza", "Licenças e Autorizações" ]

21.times do |i|
  razao_social = Faker::Company.name + " " + Faker::Company.suffix
  
  s = Supplier.create!(
    razao_social: razao_social,
    # brazilian_company_number gera um CNPJ matematicamente válido
    cnpj: Faker::Company.brazilian_company_number(formatted: true),
    contato: Faker::Name.name,
    email_contato: Faker::Internet.unique.email(name: razao_social.parameterize),
    phone_contato: Faker::PhoneNumber.cell_phone,
    tipo_servico: servicos[i],
    avaliacao_media: rand(4.0..5.0).round(1)
  )

  SupplierContract.create!(
    supplier: s, 
    event: event_futuro, 
    valor: rand(3000..15000).to_f, 
    status: "signed", 
    assinado_em: Date.today
  )
end

# 7. Patrocinadores e Contratos
puts "Criando Patrocinadores..."
cotas = ["Diamante", "Ouro", "Prata", "Prata", "Ouro"] # Ajustado para 5 iterações

5.times do |i|
  nome_patrocinador = Faker::Company.name
  
  sp = Sponsor.create!(
    nome: nome_patrocinador,
    cnpj: Faker::Company.brazilian_company_number(formatted: true),
    contato: Faker::Name.name,
    email_contato: Faker::Internet.unique.email(name: nome_patrocinador.parameterize),
    phone_contato: Faker::PhoneNumber.cell_phone,
    ativo: true
  )

  SponsorContract.create!(
    event: event_futuro, 
    sponsor: sp, 
    valor_cota: (15000.0 / (i + 1)).round(2), 
    cota: cotas[i], 
    status: "signed"
  )
end

# 8. Voluntários, Postos e Escalas
puts "Escalando Voluntários..."

# Buscamos a primeira distância do evento futuro para associar ao posto de voluntário
distancia_para_posto = event_futuro.distances.first 

20.times do |i|
  primeiro_nome = Faker::Name.first_name
  sobrenome = Faker::Name.last_name
  nome_completo = "#{primeiro_nome} #{sobrenome}"
  v = Volunteer.create!(
    nome: nome_completo, 
    email: "#{primeiro_nome.parameterize}#{i}@email.com",
    telefone: Faker::PhoneNumber.cell_phone,
    funcao_preferida: "Percurso"
  )
  
  # Criar Posto se for o primeiro loop
  if i == 0
    # Trocado 'dist' por 'distancia_para_posto'
    @station = VolunteerStation.create!(
      event: event_futuro, 
      distance: distancia_para_posto, 
      nome: "Hidratação KM 5", 
      tipo: "Hidratação", 
      km_posicao: 2.0, 
      vagas: 20
    )
  end

  VolunteerShift.create!(
    volunteer: v, 
    volunteer_station: @station, 
    turno: "manha", 
    status: "confirmado"
  )
end

# 5. EVENTOS FINALIZADOS (3 Eventos com Resultados e Ranking)
puts "Criando 3 Eventos Finalizados com rankings reaise fotos..."

# Mapeamento de fotos específicas por evento
fotos_por_evento = {
  "Circuito das Estações" => ["circuito_estacoes_largada.png", "circuito_estacoes_corrida_1.png", "circuito_estacoes_chegada.png", "circuito_estacoes_podio.png"],
  "Urban Night Run" => ["night_run_largada.png", "night_run_corrida_1.png", "night_run_chegada.png", "night_run_podio.png"],
  "Copa de Inverno 2025" => ["inverno_2025_largada.png", "inverno_2025_corrida_1.png", "inverno_2025_chegada", "inverno_2025_podio"] 
}

banner_por_evento = {
  "Copa de Inverno 2025" => "banner_inverno_2025.png",
  "Circuito das Estações" => "banner_circuito_estacoes.png",
  "Urban Night Run" => "banner_night_run.png"
}

# Fotos genéricas de atletas para todos os eventos
fotos_atletas_base = ["corrida_1.jpg", "corrida_2.jpg", "corrida_3.jpeg", "corrida_4.jpeg", "corrida_5.jpg", "corrida_6.jpeg", "corrida_7.jpg", "corrida_8.jpg"]

["Copa de Inverno 2025", "Circuito das Estações", "Urban Night Run"].each_with_index do |nome_p, e_idx|
  past_event = Event.create!(
    nome: nome_p, data_largada: (e_idx + 1).months.ago,
    slug_url: nome_p.parameterize, status: "finished",
    cidade: "Rio de Janeiro", estado: "RJ", local_partida: "Praça Mauá",
    horario_largada: "08:00", limite_atletas: 500, organizer: admin
  )

  #  Lógica para anexar o banner
  filename = banner_por_evento[nome_p]
  
  if filename
    path = Rails.root.join("app/assets/images", filename)
    
    if File.exist?(path)
      # Anexamos ao past_event (e não a 'photo')
      past_event.banner.attach(
        io: File.open(path), 
        filename: filename,
        content_type: "image/png" # Ou image/jpeg dependendo do arquivo
      )
      puts "  -> Banner anexado para: #{nome_p}"
    else
      puts "  -> [AVISO] Arquivo não encontrado em: #{path}"
    end
  end

  [ {n: "5K", k: 5.0}, {n: "10K", k: 10.0} ].each do |d_info|
    dist_p = Distance.create!(event: past_event, nome: d_info[:n], km: d_info[:k], vagas_total: 300)
    
    cats_p = ["masculino Sub-40", "feminino Sub-40", "masculino 40+", "feminino 40+"].map do |cn|
      Category.create!(distance: dist_p, nome: cn, sexo: cn.include?("masculino") ? "masculino" : "feminino", idade_min: 18, idade_max: 99)
    end
    
    lote_p = Lot.create!(distance: dist_p, numero: 1, preco: 60.0, vagas: 300, abertura: 6.months.ago, encerramento: past_event.data_largada, status: "ativo")

    # Registrar atletas e gerar tempos
    inscricoes_temp = []
    # Distribuir atletas entre as distâncias
    atletas_selecionados = (d_info[:n] == "5K") ? atletas_globais.select(&:id).first(100) : atletas_globais.select(&:id).last(99)
    dorsal_base = (e_idx * 2000) + (d_info[:n] == "5K" ? 1 : 500)

    atletas_selecionados.each_with_index do |atleta, a_idx|
      cat = cats_p.find { |c| c.sexo == (atleta.sexo == "masculino" ? "masculino" : "feminino") }
      reg = Registration.create!(
        athlete: atleta, 
        event: past_event, 
        distance: dist_p, 
        category: cat, 
        lot: lote_p,
        status: "checked_in", 
        aceite_lgpd: true,
        tamanho_kit: "M",
        contato_emergencia: Faker::Name.name,
        fone_emergencia: Faker::PhoneNumber.cell_phone,
        # Garantimos um range diferente para cada evento passado para não colidir
        numero_dorsal: dorsal_base + a_idx,  #(e_idx + 1) * 2000 + a_idx, # <--- EX: Evento 1: 2000, 2001... Evento 2: 4000, 4001...
        data_inscricao: past_event.data_largada - 1.month
      )
      Distance.increment_counter(:vagas_ocupadas, dist_p.id)
      # Gerar tempo em segundos (5K: 15-40min | 10K: 35-80min)
      segundos = (d_info[:n] == "5K") ? rand(900..2400) : rand(2100..4800)
      inscricoes_temp << { reg: reg, segundos: segundos }
    end

    # Ordenar por tempo para calcular Ranking Geral e por Categoria
    ranked = inscricoes_temp.sort_by { |i| i[:segundos] }
    
    ranked.each_with_index do |item, g_idx|
      pos_cat = ranked[0..g_idx].select { |r| r[:reg].category_id == item[:reg].category_id }.count
      
      tempo_l = format("%02d:%02d:%02d", item[:segundos]/3600, (item[:segundos]%3600)/60, item[:segundos]%60)
      
      res = Result.create!(
        registration: item[:reg], event: past_event,
        posicao_geral: g_idx + 1, posicao_categoria: pos_cat,
        tempo_liquido: tempo_l, tempo_bruto: tempo_l, # Simplificado para o seed
        status_finalizacao: "concluido", homologado: true, homologado_em: past_event.data_largada + 1.day
      )

      # Adicionar NPS aleatório
      if rand < 0.3
        NpsResponse.create!(athlete: item[:reg].athlete, event: past_event, result: res, nota_geral: rand(8..10), comentario: "Top!")
      end
    end
  end

  puts "  -> Gerando fotos para #{nome_p}..."

  # 1. Criar Fotos do Evento (Tipo: evento)
  fotos_evento = fotos_por_evento[nome_p] || []
  fotos_evento.each do |filename|
    path = Rails.root.join("app/assets/images", filename)
    if File.exist?(path)
      photo = Photo.create!(
        event: past_event,
        tipo: "evento",
        enviada_em: past_event.data_largada,
        reconhecido_ia: false
      )
      photo.arquivo.attach(io: File.open(path), filename: filename)
    end
  end

  # 2. Criar Fotos de Atletas (Tipo: atleta) e vincular via PhotoRegistration
  # Vamos selecionar 5 fotos aleatórias da lista de atletas para cada evento
  fotos_atletas_base.sample(8).each do |filename|
    path = Rails.root.join("app/assets/images", filename)
    if File.exist?(path)
      photo = Photo.create!(
        event: past_event,
        tipo: "atleta",
        enviada_em: past_event.data_largada,
        reconhecido_ia: true # Simulamos que a IA já identificou
      )
      photo.arquivo.attach(io: File.open(path), filename: filename)

      # Selecionar de 1 a 3 inscrições aleatórias DESTE evento para marcar na foto
      past_event.registrations.sample(rand(1..3)).each do |reg|
        PhotoRegistration.create!(
          photo: photo,
          registration: reg,
          confianca_ocr: rand(85..99),
          confirmado_manualmente: [true, false].sample
        )
      end
    end
  end
end

# 9. Campanhas de E-mail
EmailCampaign.create!(event: event_futuro, assunto: "Inscrições Abertas!", segmento: "todos", enviados: 500, enviado_em: 1.day.ago)

puts "--- Seeds concluídos com sucesso! ---"
puts "Admin: admin@urbanrace.com | Senha: password123"
puts "Staff(Operation): staff@urbanrace.com | Senha: password123"
puts "Atleta: atleta1@email.com | Senha: password123"
puts "Atletas Criados: #{Athlete.count}"
puts "Resultados Gerados: #{Result.count}"