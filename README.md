# 🏃 Sistema de Gestão de Corridas de Rua

<div align="center">

<img src="public/images/logo_urbanrace_3d.png" alt="UrbanRace - Sistema de Gestão de Corridas de rua" width="600">

![Ruby](https://img.shields.io/badge/Ruby-3.3.0-CC342D?style=for-the-badge&logo=ruby&logoColor=white)
![Rails](https://img.shields.io/badge/Rails-8.1-CC0000?style=for-the-badge&logo=ruby-on-rails&logoColor=white)
![PostgreSQL](https://img.shields.io/badge/PostgreSQL-16-4169E1?style=for-the-badge&logo=postgresql&logoColor=white)
![Tailwind CSS](https://img.shields.io/badge/Tailwind_CSS-3.x-06B6D4?style=for-the-badge&logo=tailwind-css&logoColor=white)
![License](https://img.shields.io/badge/Licença-MIT-green?style=for-the-badge)

**Plataforma completa para promover, organizar e executar corridas de rua.**  
Do cadastro do atleta à publicação dos resultados — tudo em um só lugar.

[Funcionalidades](#-funcionalidades) •
[Tecnologias](#-tecnologias) •
[Instalação](#-instalação) •
[Como usar](#-como-usar) •
[Arquitetura](#-arquitetura) •
[Contribuindo](#-contribuindo)

</div>

---

## 📋 Índice

- [Sobre o projeto](#-sobre-o-projeto)
- [Funcionalidades](#-funcionalidades)
- [Tecnologias](#-tecnologias)
- [Pré-requisitos](#-pré-requisitos)
- [Instalação](#-instalação)
- [Variáveis de ambiente](#-variáveis-de-ambiente)
- [Como executar](#-como-executar)
- [Como usar](#-como-usar)
- [Arquitetura do sistema](#-arquitetura-do-sistema)
- [Banco de dados](#-banco-de-dados)
- [Testes](#-testes)
- [Deploy](#-deploy)
- [Contribuindo](#-contribuindo)
- [Licença](#-licença)

---

# MegaStats

## Documentação

- [Requisitos](requisitos.md)
- [Plano de Desenvolvimento](plano_desenvolvimento.md)

---

## 🎯 Sobre o projeto

O **Urbanrace** é um sistema web desenvolvido para empresas e organizadores que promovem, organizam e executam eventos de corrida de rua. A plataforma cobre **todo o ciclo de vida** de um evento esportivo, desde a divulgação e abertura de inscrições até a publicação de resultados e certificados digitais.

### O problema que resolve

Organizar uma corrida de rua envolve dezenas de processos simultâneos: divulgar o evento, gerenciar inscrições, controlar pagamentos, escalar voluntários, contratar fornecedores, obter licenças, fazer o check-in no dia, cronometrar atletas e publicar resultados. Sem um sistema centralizado, tudo isso é feito com planilhas, WhatsApp e ferramentas desconexas — o que gera erros, retrabalho e má experiência para os atletas.

O UrbanRace resolve isso com **um único sistema integrado**, acessível tanto pelo organizador quanto pelo atleta.

---

## ✨ Funcionalidades

### Para o Organizador (Painel Admin)

#### 📣 Módulo de Promoção

- Criação e edição do site público do evento com CMS integrado
- Contador regressivo até a largada
- Mapa interativo do percurso (Google Maps / Mapbox)
- Calendário editorial de posts para redes sociais
- Gestão de patrocinadores com cotas (ouro, prata, bronze, apoio)
- Links de indicação rastreáveis por parceiro/influenciador
- Campanhas de e-mail marketing segmentadas por perfil de atleta
- Dashboard de analytics do funil de conversão (visitas → inscrições)

#### 📝 Módulo de Inscrições

- Controle de vagas por distância e categoria
- Lotes de preço progressivos com virada **automática** por data ou quantidade
- Cupons de desconto (percentual ou valor fixo)
- Lista de espera automática com notificação quando vaga abre
- Agendamento de slots para retirada de kit
- Exportação da lista de inscritos em CSV
- Gestão de cancelamentos com regras de reembolso configuráveis

#### 🗂️ Módulo de Organização

- Percurso no mapa com pontos de hidratação, postos médicos e cronometragem
- Gestão de fornecedores com contratos, marcos de entrega e pagamentos
- Avaliação de fornecedores pós-evento
- Escala de voluntários por posto com convite por e-mail
- Controle de licenças e autorizações com alertas de prazo
- Checklist operacional por fase do evento (90 dias, 30 dias, 7 dias, dia do evento)
- Painel de status com semáforo (verde/amarelo/vermelho) por área

#### 🏁 Módulo de Execução (Dia do Evento)

- Check-in de atletas por QR Code via app mobile
- **Modo offline** — funciona sem internet e sincroniza ao reconectar
- Associação dorsal ↔ chip ↔ atleta com verificação tripla
- Registro de gun time por onda de largada
- Importação de chip time do fornecedor de cronometragem (CSV ou API)
- Ranking provisório em **tempo real** atualizado a cada passagem
- Detecção automática de DNS (não largou) e DNF (não chegou)
- Comunicação interna entre postos (chat por setor)
- Registro e acionamento de ocorrências médicas com um toque

#### 🏅 Módulo de Pós-evento

- Homologação de resultados com correção manual antes da publicação
- Ranking oficial (geral, por categoria, por sexo, por faixa etária)
- Geração em lote de certificados digitais com QR Code de autenticidade
- Galeria de fotos com identificação de dorsal por IA (OCR)
- Pesquisa de satisfação NPS automatizada 24h após o evento
- Dashboard NPS com comparativo histórico entre edições
- Relatório financeiro (receita por lote, custo por atleta, margem)
- Relatório operacional (DNS/DNF, ocorrências, avaliação de fornecedores)

---

### Para o Atleta (Área Pública)

- Cadastro e login **sem Devise** — autenticação nativa Rails (`has_secure_password`)
- Busca e filtragem de eventos disponíveis
- Formulário de inscrição responsivo com upload de atestado médico
- Pagamento via **Pix** (aprovação em até 5 min), **cartão de crédito** (até 6x) e **boleto**
- Aplicação de cupom de desconto no checkout
- Área do corredor com QR Code de check-in e número do dorsal
- Agendamento de horário para retirada do kit
- Transferência de vaga para outro atleta
- Consulta de resultado com splits por ponto de passagem
- Download do certificado digital
- Busca de fotos pelo número do dorsal

---

## 🛠️ Tecnologias

| Camada           | Tecnologia                            | Versão                    |
| ---------------- | ------------------------------------- | ------------------------- |
| Linguagem        | Ruby                                  | 3.3.0                     |
| Framework        | Ruby on Rails                         | 8.1                       |
| Banco de dados   | PostgreSQL                            | 16                        |
| Front-end        | Tailwind CSS                          | 3.x (CDN)                 |
| Reatividade      | Hotwire (Turbo + Stimulus)            | Rails nativo              |
| Autenticação     | `has_secure_password`                 | Rails nativo (sem Devise) |
| Background jobs  | Solid Queue                           | Rails 8 nativo            |
| Cache            | Solid Cache                           | Rails 8 nativo            |
| ActiveStorage    | Local (dev) / AWS S3 (prod)           | Rails nativo              |
| Envio de e-mails | SendGrid (prod) / Letter Opener (dev) | —                         |
| PDF              | Prawn                                 | 2.x                       |
| QR Code          | rqrcode                               | —                         |
| Paginação        | Kaminari                              | —                         |
| Servidor web     | Puma                                  | 5+                        |

---

## 📦 Pré-requisitos

Antes de começar, certifique-se de ter instalado:

- **Ruby** 3.3.0 — recomendado via [rbenv](https://github.com/rbenv/rbenv) ou [asdf](https://asdf-vm.com/)
- **Rails** 8.1+
- **PostgreSQL** 16+
- **Node.js** 18+ (para assets)
- **Git**

### Verificando as versões

```bash
ruby --version      # ruby 3.3.0
rails --version     # Rails 8.1.x
psql --version      # psql (PostgreSQL) 12.x
node --version      # v18.x ou superior
```

---

## 🚀 Instalação

### 1. Clone o repositório

```bash
git clone https://github.com/VulcanoBr/UrbanRace
cd urbanrace
```

### 2. Instale as dependências Ruby

```bash
bundle install
```

### 3. Configure as variáveis de ambiente

```bash
cp .env.example .env
```

Edite o arquivo `.env` com suas configurações (veja a seção [Variáveis de ambiente](#-variáveis-de-ambiente)).

### 4. Crie e prepare o banco de dados

```bash
rails db:create
rails db:migrate
rails db:seed
```

> O comando `db:seed` cria um usuário administrador e um evento de exemplo para desenvolvimento. Veja as credenciais ao final da execução.

### 5. Inicie o servidor

```bash
bin/dev
```

Acesse em: **http://localhost:3000**

---

## 🔑 Variáveis de ambiente

Crie um arquivo `.env` na raiz do projeto com as seguintes variáveis:

```env
# ── Banco de dados ─────────────────────────────────────────────────────────
DATABASE_URL=postgresql://postgres:senha@localhost/corridas_app_development
DB_USERNAME=postgres
DB_PASSWORD=sua_senha
DB_HOST=localhost
DB_PORT=5432

# ── Aplicação ──────────────────────────────────────────────────────────────
APP_HOST=localhost:3000
SECRET_KEY_BASE=chave_gerada_com_rails_secret

# ── E-mail ─────────────────────────────────────────────────────────────────
MAILER_FROM=noreply@UrbanRace.com.br
SENDGRID_API_KEY=SG.xxxxxxxxxxxx          # apenas produção

# ── Gateway de pagamento ───────────────────────────────────────────────────
PAGAMENTO_PROVIDER=mercadopago            # mercadopago | pagseguro | stripe
MERCADOPAGO_ACCESS_TOKEN=APP_USR-xxx
MERCADOPAGO_WEBHOOK_SECRET=seu_secret

# ── Storage (produção) ─────────────────────────────────────────────────────
AWS_ACCESS_KEY_ID=AKIA...
AWS_SECRET_ACCESS_KEY=xxxx
AWS_REGION=us-east-1
AWS_BUCKET=corridas-app-production

# ── IA para reconhecimento de dorsais (Fase 4) ─────────────────────────────
GOOGLE_VISION_API_KEY=AIza...
```

> **⚠️ Nunca commite o arquivo `.env` no repositório.** Ele já está no `.gitignore`.

Para gerar a `SECRET_KEY_BASE`:

```bash
rails secret
```

---

## ▶️ Como executar

### Desenvolvimento

```bash
# Iniciar todos os processos (web + jobs)
bin/dev

# Apenas o servidor Rails
rails server

# Apenas o Solid Queue (background jobs)
bundle exec rake solid_queue:start
```

### Console Rails

```bash
rails console
```

### Rodar as migrations

```bash
rails db:migrate

# Desfazer a última migration
rails db:rollback

# Status das migrations
rails db:migrate:status
```

### Repovoar o banco em desenvolvimento

```bash
rails db:seed

# Reset completo (apaga tudo e recria)
rails db:reset
```

---

## 🧭 Como usar

### Acessos após `db:seed`

| Perfil               | E-mail              | Senha       | URL        |
| -------------------- | ------------------- | ----------- | ---------- |
| **Administrador**    | admin@urbanrace.com | password123 | /admin     |
| **Operador / Staff** | staff@urbanrace.com | password123 | /operation |
| **Atleta de teste**  | atleta1@email.com   | password123 | /login     |

### Fluxo básico do organizador

```
1. Login em /admin
2. Criar evento em Admin → Eventos → Novo
3. Adicionar distâncias e categorias ao evento
4. Criar lotes de preço (1º lote: abertura, encerramento, preço, vagas)
5. Publicar o evento → status "Inscrições abertas"
6. Atletas se inscrevem em /eventos/:slug
7. Dia do evento: check-in via QR Code em Admin → Checkins
8. Registrar gun time em Admin → Largadas
9. Importar cronometragem em Admin → Resultados
10. Homologar e publicar resultados → certificados gerados automaticamente
```

### Fluxo básico do atleta

```
1. Cadastro em /cadastrar
2. Buscar eventos em /eventos
3. Clicar em "Inscrever-se" e preencher o formulário
4. Pagar via Pix, cartão ou boleto
5. Receber e-mail de confirmação com QR Code e dorsal
6. Retirar kit apresentando o QR Code na expo
7. Participar do evento → check-in automático pelo QR Code
8. Receber e-mail com resultado e certificado
```

---

## 🏛️ Arquitetura do sistema

```
corridas-app/
│
├── app/
│   ├── controllers/
│   │   ├── application_controller.rb      # Base com autenticação e auditoria
│   │   ├── concerns/
│   │   │   ├── authenticatable.rb         # Login de atleta e organizador
│   │   │   ├── auditable.rb               # Log de auditoria de ações
│   │   │   └── error_handleable.rb        # Tratamento global de erros
│   │   ├── admin/                         # Todos os controllers do painel admin
│   │   │   ├── base_controller.rb
│   │   │   ├── eventos_controller.rb
│   │   │   ├── inscricoes_controller.rb
│   │   │   ├── checkins_controller.rb
│   │   │   ├── resultados_controller.rb
│   │   │   └── ...                        # demais controllers admin
│   │   ├── eventos_controller.rb          # Página pública dos eventos
│   │   ├── inscricoes_controller.rb       # Fluxo de inscrição do atleta
│   │   ├── pagamentos_controller.rb       # Checkout e webhook do gateway
│   │   ├── area_corredor_controller.rb    # Portal do atleta logado
│   │   └── ...
│   │
│   ├── models/
│   │   ├── concerns/
│   │   │   ├── searchable.rb              # Busca por nome com unaccent
│   │   │   └── auditable.rb
│   │   ├── atleta.rb
│   │   ├── evento.rb
│   │   ├── distancia.rb
│   │   ├── categoria.rb
│   │   ├── lote.rb
│   │   ├── inscricao.rb                   # Core: vagas, dorsal, QR Code
│   │   ├── pagamento.rb
│   │   ├── resultado.rb
│   │   ├── certificado.rb
│   │   └── ...                            # 39 models no total
│   │
│   ├── services/                          # Lógica de negócio fora dos models
│   │   ├── application_service.rb         # Base com Result struct
│   │   ├── inscricao/
│   │   │   ├── criar_service.rb
│   │   │   ├── cancelar_service.rb
│   │   │   ├── transferir_service.rb
│   │   │   └── exportar_csv_service.rb
│   │   ├── pagamento/
│   │   │   ├── processar_service.rb
│   │   │   ├── processar_webhook_service.rb
│   │   │   └── estornar_service.rb
│   │   ├── execucao/
│   │   │   ├── checkin_service.rb
│   │   │   └── importar_cronometragem_service.rb
│   │   └── pos_evento/
│   │       ├── homologar_resultados_service.rb
│   │       ├── calcular_ranking_service.rb
│   │       ├── gerar_certificado_service.rb
│   │       └── enviar_nps_service.rb
│   │
│   ├── jobs/                              # Background jobs (Solid Queue)
│   │   ├── lote_virada_job.rb             # Vira lotes automaticamente (a cada 1 min)
│   │   ├── pagamento_expirar_job.rb       # Expira Pix/boleto vencidos
│   │   ├── certificado_gerar_job.rb       # Gera PDF do certificado
│   │   ├── campanha_email_job.rb          # Dispara e-mails em lote
│   │   ├── nps_enviar_job.rb              # Envia pesquisa NPS
│   │   ├── notificacao_lembrete_kit_job.rb
│   │   └── alerta_licenca_job.rb
│   │
│   ├── mailers/                           # 11 mailers com templates HTML
│   │   ├── atleta_mailer.rb               # Boas-vindas, recuperação de senha
│   │   ├── inscricao_mailer.rb            # Confirmação, lembrete de kit
│   │   ├── pagamento_mailer.rb            # Pix, boleto, estorno
│   │   ├── atleta_resultado_mailer.rb     # Resultado e certificado
│   │   ├── nps_mailer.rb                  # Pesquisa de satisfação
│   │   └── ...
│   │
│   └── views/
│       ├── layouts/
│       │   ├── application.html.erb       # Layout público (Tailwind CDN)
│       │   ├── admin.html.erb             # Layout admin com sidebar
│       │   └── mailer.html.erb            # Layout de e-mails HTML
│       └── ...                            # 88 views ERB no total
│
├── config/
│   ├── routes.rb                          # Rotas públicas e namespace :admin
│   ├── application.rb                     # Configuração da app (pt-BR, Solid Queue)
│   ├── database.yml
│   ├── environments/                      # development, test, production
│   ├── initializers/                      # inflections, cors, session_store, etc.
│   └── locales/pt-BR.yml                  # Tradução completa para português
│
└── db/
    ├── migrate/                           # 38 migrations
    └── seeds.rb                           # Dados de desenvolvimento
```

### Padrão de Services

Todos os services seguem o padrão `Result`:

```ruby
# Chamada
resultado = Inscricao::CriarService.new(
  atleta: atleta,
  evento: evento,
  params: inscricao_params
).executar

# Verificação
if resultado.sucesso?
  redirect_to pagamento_path(resultado.inscricao)
else
  flash[:alert] = resultado.erros.to_sentence
  render :new
end
```

---

## 🗄️ Banco de dados

O sistema possui **38 tabelas** organizadas por domínio:

### Domínio: Usuários

| Tabela                 | Descrição                                       |
| ---------------------- | ----------------------------------------------- |
| `atletas`              | Atletas/corredores cadastrados                  |
| `organizadores`        | Usuários do painel admin                        |
| `evento_organizadores` | Relação N:N com papel (dono, coordenador, etc.) |

### Domínio: Evento e Inscrições

| Tabela                  | Descrição                                     |
| ----------------------- | --------------------------------------------- |
| `eventos`               | Dados principais do evento                    |
| `distancias`            | Distâncias disponíveis (5k, 10k, 21k, 42k)    |
| `categorias`            | Categorias por distância (sexo, faixa etária) |
| `lotes`                 | Lotes de preço com virada automática          |
| `inscricoes`            | Inscrição do atleta no evento                 |
| `pagamentos`            | Transações (Pix, cartão, boleto)              |
| `lista_esperas`         | Fila quando a categoria está esgotada         |
| `transferencias_vagas`  | Transferência entre atletas                   |
| `cupons`                | Cupons de desconto                            |
| `slots_retirada`        | Slots de horário para retirada do kit         |
| `agendamentos_retirada` | Agendamento do atleta                         |

### Domínio: Organização

| Tabela                    | Descrição                            |
| ------------------------- | ------------------------------------ |
| `percursos`               | Traçado do percurso (GeoJSON)        |
| `pontos_passagem`         | Km, tipo e coordenadas de cada ponto |
| `fornecedores`            | Cadastro global de fornecedores      |
| `contratos_fornecedores`  | Contrato por evento                  |
| `entregas_fornecedores`   | Marcos de entrega com prazo e status |
| `pagamentos_fornecedores` | Controle financeiro por contrato     |
| `avaliacoes_fornecedores` | Nota pós-evento                      |
| `voluntarios`             | Cadastro global de voluntários       |
| `postos_voluntarios`      | Postos de trabalho no evento         |
| `escalas_voluntarios`     | Alocação de voluntário no posto      |
| `licencas`                | Autorizações e alvarás               |
| `tarefas_checklist`       | Checklist operacional por fase       |

### Domínio: Execução e Pós-evento

| Tabela             | Descrição                              |
| ------------------ | -------------------------------------- |
| `checkins_atletas` | Check-in por QR Code (suporte offline) |
| `largadas`         | Gun time por onda de largada           |
| `cronometragens`   | Splits por ponto de passagem           |
| `ocorrencias`      | Ocorrências médicas e operacionais     |
| `resultados`       | Ranking oficial homologado             |
| `certificados`     | Certificados digitais com QR Code      |
| `fotos`            | Galeria com associação por dorsal      |
| `nps_respostas`    | Pesquisa de satisfação                 |

### Domínio: Promoção

| Tabela            | Descrição                          |
| ----------------- | ---------------------------------- |
| `patrocinadores`  | Patrocinadores com link rastreável |
| `campanhas_email` | Campanhas segmentadas              |
| `notificacoes`    | Histórico de notificações enviadas |

### Infraestrutura

| Tabela           | Descrição                             |
| ---------------- | ------------------------------------- |
| `logs_auditoria` | Log imutável de ações administrativas |

---

## 🧪 Testes

O projeto usa **RSpec** com **Factory Bot** e **Faker**.

```bash
# Rodar todos os testes
bundle exec rspec

# Rodar apenas uma pasta
bundle exec rspec spec/models/
bundle exec rspec spec/services/

# Com relatório de cobertura (SimpleCov)
COVERAGE=true bundle exec rspec

# Rodar um arquivo específico
bundle exec rspec spec/services/inscricao/criar_service_spec.rb
```

### Estrutura de testes recomendada

```
spec/
├── factories/          # Factory Bot factories por model
├── models/             # Validações, escopos, métodos de instância
├── services/           # Lógica de negócio — caso mais importante
├── controllers/        # Request specs (admin e públicos)
├── mailers/            # Conteúdo e destinatários dos e-mails
└── system/             # Testes de integração E2E com Capybara
```

### Configurar Solid Queue em produção

O Solid Queue roda como processo separado. Adicione ao `Procfile`:

```
web:    bundle exec puma -C config/puma.rb
worker: bundle exec rake solid_queue:start
```

### Configurar jobs recorrentes (`config/recurring.yml`)

```yaml
lote_virada:
  class: LoteViradaJob
  schedule: every 1 minute

pagamento_expirar:
  class: PagamentoExpirarJob
  schedule: every 15 minutes

lembrete_kit:
  class: NotificacaoLembreteKitJob
  schedule: every day at 8am

alerta_licenca:
  class: AlertaLicencaJob
  schedule: every day at 7am
```

---

## 🗺️ Roadmap

O sistema foi planejado em **4 fases**:

| Fase                     | Status                | Descrição                                           |
| ------------------------ | --------------------- | --------------------------------------------------- |
| **Fase 1** — MVP         | ✅ Em desenvolvimento | Site, inscrições, pagamentos, autenticação          |
| **Fase 2** — Operação    | 🔜 Planejado          | Percurso, fornecedores, check-in, cronometragem     |
| **Fase 3** — Engajamento | 🔜 Planejado          | E-mail marketing, resultados, certificados, NPS     |
| **Fase 4** — Otimização  | 🔜 Planejado          | IA p/ fotos, tracking público, app mobile, Meta Ads |

---

## 🤝 Contribuindo

Contribuições são bem-vindas! Siga os passos:

### 1. Fork o projeto

```bash
git fork https://github.com/VulcanoBr/UrbanRace
```

### 2. Crie uma branch para sua feature

```bash
git checkout -b feature/minha-nova-funcionalidade
```

### 3. Siga os padrões do projeto

- Escreva testes para qualquer funcionalidade nova
- Siga o padrão de Services para lógica de negócio
- Use o concern `Auditable` para ações administrativas sensíveis
- Mantenha as views responsivas com Tailwind CSS
- Rode o RuboCop antes do PR: `bundle exec rubocop`

### 4. Commit e push

```bash
git commit -m "feat: adiciona funcionalidade X"
git push origin feature/minha-nova-funcionalidade
```

### 5. Abra um Pull Request

Descreva o que foi feito, por que e como testar.

### Convenção de commits

```
feat:     nova funcionalidade
fix:      correção de bug
docs:     documentação
style:    formatação (sem mudança de lógica)
refactor: refatoração sem nova funcionalidade
test:     adição ou correção de testes
chore:    tarefas de manutenção
```

---

## ❓ Perguntas frequentes

**Por que não usar Devise para autenticação?**  
O Rails 8 introduziu melhorias significativas no `has_secure_password` e no sistema de sessões nativo. Para este projeto, a autenticação customizada oferece mais controle, menor dependência externa e código mais legível — suficiente para os requisitos do sistema.

**Por que Solid Queue em vez de Sidekiq?**  
O Solid Queue é nativo do Rails 8 e usa o PostgreSQL como backend — o mesmo banco já utilizado pelo projeto. Isso simplifica a infraestrutura: não é necessário configurar um servidor Redis separado em produção.

**O check-in offline funciona em tablets sem chip?**  
Sim. O app de check-in sincroniza a lista de inscritos previamente e opera por até 8 horas sem conexão, sincronizando automaticamente quando a internet retornar.

**Como integrar com outro gateway de pagamento?**  
Crie uma nova classe em `app/services/gateways/` implementando os métodos `processar(pagamento)` e `estornar(pagamento, valor)`, e configure a variável `PAGAMENTO_PROVIDER` com o novo nome.

---

## 📄 Licença

Este projeto está sob a licença **MIT**. Veja o arquivo [LICENSE](LICENSE) para mais detalhes.

---

<div align="center">

Desenvolvido com ❤️ em Ruby on Rails 8.1

**[⬆ Voltar ao topo](#-UrbanRace--sistema-de-gestão-de-corridas-de-rua)**

</div>

# README

This README would normally document whatever steps are necessary to get the
application up and running.

Things you may want to cover:

- Ruby version

- System dependencies

- Configuration

- Database creation

- Database initialization

- How to run the test suite

- Services (job queues, cache servers, search engines, etc.)

- Deployment instructions

- ...
  http://localhost:3000/jobs

  ConfirmRegistrationJob.perform_later(registration.id)

  # Testa o job para um evento específico

  LicenseAlertJob.perform_now(event_id: Event.first.id)

  # Testa o mailer isoladamente

  license = License.first
  OrganizerMailer.license_alert(
  organizer: license.event.organizer,
  event: license.event,
  license: license,
  days: 7
  ).deliver_now
