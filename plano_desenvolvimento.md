[← Voltar ao README](../README.md)

---

PLANO DE DESENVOLVIMENTO

Sistema de Gestão de Corridas de Rua

Ruby on Rails 8.1 · PostgreSQL · Metodologia Ágil

Versão 1.0 | Junho de 2026

5

Fases

20

Sprints

12

Meses

38

Módulos de BD

Confidencial — uso interno

1. Visão Geral do Plano

Este documento define as fases, sprints, entregas e critérios de aceite para o desenvolvimento do Sistema de Gestão de Corridas de Rua, construído com Ruby on Rails 8.1 e banco de dados PostgreSQL. O plano adota metodologia ágil com sprints de 2 semanas, revisões ao final de cada sprint e ciclos de feedback com o cliente.

1.1 Princípios do plano
Entrega incremental — cada fase entrega valor funcional utilizável em produção

Mobile-first — todas as interfaces projetadas primeiro para dispositivos móveis

API-first — back-end expõe API REST/JSON consumida pelo front-end e pelo app mobile

Test-driven — cobertura mínima de 80% com RSpec antes de cada deploy

Segurança e LGPD — requisitos não funcionais tratados desde a Fase 1, não como afterthought

1.2 Stack tecnológica
Camada

Tecnologia

Justificativa

Back-end

Ruby on Rails 8.1

Framework full-stack maduro, convenções sólidas, ecossistema rico de gems

Banco de dados

PostgreSQL 12

Suporte a JSON, full-text search, GiST para dados geoespaciais (percurso)

Cache

Sidekiq 7

Processamento assíncrono: e-mails, geração de certificados, OCR de fotos

Front-end

Hotwire (Turbo + Stimulus)

Padrão Rails 8, sem SPA — atualizações reativas sem complexidade de React

CSS

Tailwind CSS 4

Utilitário, sem CSS legado, responsivo por padrão

Autenticação

Devise + Warden

Gem padrão Rails com suporte a 2FA via devise-two-factor

Storage de arquivos

Active Storage + S3/R2

PDFs de certificados, contratos, atestados e fotos

Pagamentos

Mercado Pago API (webhooks)

Maior cobertura no Brasil para Pix, cartão e boleto

E-mail

SendGrid + Action Mailer

Transacional e campanhas com rastreamento de abertura

Mapas

Mapbox GL JS

Renderização de percursos GeoJSON, marcadores interativos

Testes

RSpec + FactoryBot + Capybara

Stack padrão Rails para unit, integration e system tests

CI/CD

GitHub Actions

Pipeline automático: lint, testes, deploy staging e produção

Infraestrutura

Heroku / Render / Fly.io

PaaS gerenciado, reduz overhead de DevOps na fase inicial

1.3 Resumo das fases

#

Fase

Período

Sprints

Entrega principal

F1

Fundação e MVP de Inscrições

Meses 1–3

1–6

Atletas se inscrevem e pagam online

F2

Organização e Promoção

Meses 4–6

7–12

Organizador gerencia percurso, fornecedores e marketing

F3

Execução no Dia do Evento

Meses 7–9

13–16

App de check-in, cronometragem e ocorrências ao vivo

F4

Pós-evento e Engajamento

Meses 9–11

17–19

Resultados, certificados, fotos com IA e NPS

F5

Otimização e Escala

Mês 12

20

Performance, observabilidade e features avançadas

2. Linha do Tempo Consolidada

Fase

M1

M2

M3

M4

M5

M6

M7

M8

M9

M10

M11

M12

Fundação + MVP

████

████

████

Organização + Promoção

████

████

████

Execução no Dia

████

████

████

Pós-evento + Engajam.

████

████

████

Otimização + Escala

████

3. Fase 1 — Fundação e MVP de Inscrições

F1

Fundação e MVP de Inscrições

Meses 1–3 | Sprints 1–6

Objetivo: entregar um sistema funcional onde atletas podem se inscrever, escolher categoria, pagar e receber confirmação. O organizador consegue configurar o evento, criar lotes e acompanhar inscrições em tempo real. Esta fase representa o núcleo financeiro do sistema.

3.1 Entregáveis da Fase 1
Ambiente de desenvolvimento configurado (Rails 8.1, PostgreSQL, Redis, Sidekiq)

Todas as 38 migrations executadas e validadas

Models com validações, escopos e associações (ActiveRecord)

Autenticação de atletas e organizadores (Devise + 2FA)

CRUD completo de eventos, distâncias, categorias e lotes

Formulário de inscrição responsivo com upload de atestado médico

Geração automática de QR Code e número de dorsal

Integração com Mercado Pago (Pix, cartão e boleto via webhooks)

Virada automática de lotes por data e por quantidade de vagas

Lista de espera com notificação automática

Área do corredor (portal autenticado com comprovante e QR Code)

Transferência de vaga entre atletas

Painel administrativo de inscrições com filtros e exportação CSV

E-mails transacionais via Action Mailer + SendGrid

Cobertura de testes >= 80% (RSpec + FactoryBot)

Pipeline CI/CD no GitHub Actions com deploy automático para staging

3.2 Sprints da Fase 1

Sprint 1

Setup e Fundação

Criação do projeto Rails 8.1 com configurações de ambiente

Configuração do banco PostgreSQL com todas as 38 migrations

Instalação e configuração de gems essenciais (Devise, Sidekiq, etc.)

Setup do pipeline CI/CD no GitHub Actions

Configuração do ambiente de staging (Heroku/Render)

Models iniciais: Atleta, Organizador, Evento

2 semanas

Sprint 2

Autenticação e Eventos

Autenticação completa com Devise (registro, login, recuperação de senha)

Implementação de 2FA para organizadores

CRUD de Eventos com slug automático e validações

CRUD de Distâncias e Categorias vinculadas ao evento

Seeds de desenvolvimento com dados realistas

Testes de autenticação e models (RSpec)

2 semanas

Sprint 3

Lotes e Controle de Vagas

CRUD de Lotes com virada automática via ActiveJob + Sidekiq

Controle de vagas com lock otimista (optimistic locking)

Formulário de inscrição etapa 1 (dados pessoais + categoria)

Upload de atestado médico com Active Storage + validação

Aceite LGPD com registro de IP e timestamp

Geração de QR Code hash único por inscrição

2 semanas

Sprint 4

Pagamentos

Integração Mercado Pago: Pix com QR Code e copia-e-cola

Integração cartão de crédito (até 6x) e débito

Integração boleto bancário com reserva de vaga por 3 dias

Webhook handler para confirmação automática de pagamentos

Geração de dorsal após pagamento confirmado

E-mail de confirmação de inscrição com comprovante

2 semanas

Sprint 5

Lista de Espera e Transferências

Módulo de lista de espera com fila ordenada por data

Notificação automática ao próximo da fila quando vaga libera

Módulo de transferência de vaga com aprovação e taxa

Módulo de cancelamento com regras de reembolso configuráveis

Estorno automático via Mercado Pago API

Testes de integração do fluxo completo de pagamento

2 semanas

Sprint 6

Área do Corredor e Painel Admin

Portal autenticado do atleta: comprovante, QR Code e dorsal

Agendamento de slot para retirada de kit

Painel administrativo de inscrições com filtros avançados

Exportação CSV e Excel da lista de inscritos

Cupons de desconto (percentual e valor fixo)

Revisão geral, cobertura de testes >= 80% e demo com cliente

2 semanas

3.3 Critérios de aceite da Fase 1

#

Critério

Como verificar

FA1-01

Atleta completa inscrição e recebe e-mail de confirmação em menos de 5 minutos

Teste de integração end-to-end com Capybara

FA1-02

Virada de lote ocorre automaticamente no horário configurado sem intervenção manual

Teste com Timecop simulando mudança de data

FA1-03

Pagamento Pix confirmado em até 5 minutos após simulação do webhook

Teste com mock do webhook do Mercado Pago

FA1-04

Vagas bloqueadas corretamente quando limite atingido (sem race condition)

Teste de carga com 50 requisições simultâneas

FA1-05

QR Code de cada atleta é único e válido

Verificação de unicidade em banco + teste de decodificação

FA1-06

Exportação CSV da lista de inscritos gera arquivo correto

Comparação do CSV gerado com fixture esperado

FA1-07

Cobertura de testes >= 80% no relatório do SimpleCov

Execução do pipeline CI com SimpleCov

4. Fase 2 — Organização e Promoção

F2

Organização e Promoção

Meses 4–6 | Sprints 7–12

Objetivo: dar ao organizador ferramentas completas para planejar a logística do evento (percurso, fornecedores, voluntários, licenças, checklist) e promovê-lo digitalmente (site, e-mail marketing, patrocinadores e analytics de funil).

4.1 Entregáveis da Fase 2
Site do evento com CMS (página pública do evento gerenciada pelo organizador)

Contador regressivo dinâmico para a data da largada

Editor de percurso com integração Mapbox (traçado + pontos de apoio)

Gestão completa de fornecedores (cadastro, orçamentos, contratos, entregas)

Controle financeiro de pagamentos a fornecedores (NF, comprovante)

Avaliação de fornecedores por edição

Cadastro e escala de voluntários por posto

Gestão de licenças e autorizações com semáforo de status

Checklist operacional por fase com responsável e prazo

Painel de status do evento (visão consolidada com alertas)

Módulo de e-mail marketing com segmentação e agendamento

Cadastro de patrocinadores com links de indicação rastreáveis

Analytics do funil (visitas, conversão, custo por inscrição por canal)

Notificações automáticas (lembretes de kit, alertas de prazo)

4.2 Sprints da Fase 2

Sprint 7

Site do Evento e CMS

Geração automática da página pública do evento (slug único)

Editor de conteúdo: logo, banner, descrição, regulamento e FAQ

Contador regressivo dinâmico com Stimulus.js

Galeria de fotos de edições anteriores no site

Botão de inscrição integrado ao formulário (Fase 1)

SEO básico: meta tags, Open Graph e sitemap XML

2 semanas

Sprint 8

Percurso com Mapbox

Integração Mapbox GL JS para edição de percursos

Salvar traçado como GeoJSON no banco (PostgreSQL)

Marcadores para largada, chegada, hidratação e postos médicos

Suporte a múltiplos percursos por evento (5k, 10k, 21k)

Exportação do mapa público para o site do evento

Testes de serialização/deserialização do GeoJSON

2 semanas

Sprint 9

Gestão de Fornecedores

CRUD de Fornecedores com histórico de eventos anteriores

Cadastro de orçamentos e seleção da proposta vencedora

Upload de contratos em PDF (Active Storage)

Módulo de entregas com marcos, status e alertas de prazo

Controle de pagamentos (previsto/liberado/pago com NF)

Avaliação pós-evento por critério (prazo, qualidade, atendimento)

2 semanas

Sprint 10

Voluntários e Licenças

CRUD de Voluntários com histórico e função preferida

Criação de Postos de Voluntários por evento e distância

Escala automática com confirmação por e-mail

Check-in de voluntários via app no dia (preparação da Fase 3)

Gestão de Licenças com semáforo e alertas 30/15/7 dias antes

Checklist operacional por fase com responsável e status

2 semanas

Sprint 11

E-mail Marketing e Patrocinadores

Editor de campanhas de e-mail com templates por evento

Segmentação: inscritos, lista de espera, veteranos, novo atleta

Agendamento de envio com Sidekiq

Rastreamento de abertura e cliques (webhooks SendGrid)

Cadastro de patrocinadores com cotas e geração de links rastreáveis

Contador de inscrições originadas por link de indicação

2 semanas

Sprint 12

Analytics e Painel de Status

Painel de analytics: visitas, conversão e custo por inscrição por canal

Semáforo de status do evento por área (inscrições, fornecedores, licenças, percurso)

Alertas automáticos quando área entra em risco (vermelho)

Relatório de patrocinadores com visibilidade estimada

Refinamentos de UX baseados no feedback da Fase 1

Demo com cliente, cobertura de testes e homologação

2 semanas

4.3 Critérios de aceite da Fase 2

#

Critério

Como verificar

FA2-01

Site do evento publicado e acessível via slug único em menos de 1 segundo

Teste de performance com Lighthouse >= 90

FA2-02

Percurso salvo em GeoJSON e renderizado corretamente no Mapbox

Teste visual + validação do GeoJSON gerado

FA2-03

Alerta de licença enviado com 30, 15 e 7 dias de antecedência

Teste com Timecop + verificação de e-mail enviado

FA2-04

Campanha de e-mail entregue ao segmento correto

Teste com fixture de segmentação + log SendGrid

FA2-05

Painel de status exibe vermelho quando licença está pendente

Teste de sistema com Capybara

FA2-06

Link de indicação do patrocinador registra inscrições corretamente

Teste de rastreamento UTM + contador de banco

5. Fase 3 — Execução no Dia do Evento

F3

Execução no Dia do Evento

Meses 7–9 | Sprints 13–16

Objetivo: entregar um conjunto de ferramentas que funcione de forma confiável no dia da corrida, incluindo app de check-in offline, integração com cronometragem, ranking ao vivo, comunicação entre equipes e gestão de ocorrências médicas em tempo real.

5.1 Entregáveis da Fase 3
App de check-in mobile (Hotwire/PWA) com modo offline obrigatório

Sincronização de check-ins após reconexão sem duplicatas

Associação dorsal ↔ chip ↔ atleta no check-in

Registro de gun time com suporte a múltiplas ondas de largada

Importação de chip time e splits via API ou arquivo CSV do fornecedor

Ranking em tempo real atualizado em até 10 segundos

Painel público de tracking (familiares acompanham pelo dorsal)

Chat interno por setor (Turbo Streams via ActionCable)

Registro de ocorrências médicas e operacionais com acionamento automático

Fluxo de encerramento do percurso (último atleta, DNS/DNF, resultados preliminares)

Painel de presença com percentual de credenciados por categoria

Premiação e registro de pódio por categoria

5.2 Sprints da Fase 3

Sprint 13

App de Check-in Offline

PWA com Service Worker para operação offline (8h sem internet)

Sincronização automática ao reconectar com resolução de conflitos

Leitura de QR Code via câmera do dispositivo (jsQR library)

Validação imediata da inscrição no banco local (SQLite via Litestream)

Associação dorsal-chip com dupla confirmação

Painel de presença por categoria em tempo real

2 semanas

Sprint 14

Cronometragem e Ranking

Registro de gun time por onda de largada

Importador de chip time via API REST e upload de CSV

Cálculo automático de chip_time_ms e pace_km

Ranking em tempo real com Turbo Streams (ActionCable + Redis)

Splits por ponto de passagem exibidos na página individual do atleta

Detecção automática de DNS e DNF por tempo limite

2 semanas

Sprint 15

Painel Público e Comunicação

Página pública de tracking: busca por dorsal sem login

Atualização automática da posição a cada 15 segundos (Turbo Streams)

Chat interno por setor com broadcast geral (ActionCable)

Solicitação de reabastecimento de recursos pelos postos

Painel da coordenação com visão de todos os postos e status

Testes de carga do ranking ao vivo com 500 conexões simultâneas

2 semanas

Sprint 16

Ocorrências e Encerramento

Formulário rápido de ocorrência médica com GPS e km aproximado

Acionamento automático do contato de emergência do atleta

Alerta para ambulância mais próxima (push notification)

Registro de ocorrências operacionais com responsável e prazo

Fluxo de encerramento: confirmação do último atleta, publicação de resultados preliminares

Registro do pódio e cerimônia de premiação

2 semanas

5.3 Critérios de aceite da Fase 3

#

Critério

Como verificar

FA3-01

App de check-in opera sem internet por 8 horas e sincroniza sem perda de dados

Teste simulando desconexão de rede por 8h com 500 check-ins

FA3-02

Ranking atualizado em até 10 segundos após importação de chip time

Teste de performance com cronômetro e 1.000 resultados

FA3-03

Painel público exibe posição do atleta pelo dorsal sem login

Teste de sistema com Capybara em modo anônimo

FA3-04

Ocorrência médica dispara notificação ao contato de emergência em até 60 segundos

Teste de integração com mock de push notification

FA3-05

DNS e DNF detectados automaticamente após tempo limite configurado

Teste com Timecop + verificação de status na inscrição

6. Fase 4 — Pós-evento e Engajamento

F4

Pós-evento e Engajamento

Meses 9–11 | Sprints 17–19

Objetivo: transformar a experiência da corrida em engajamento duradouro. O atleta recebe resultados rápidos, certificado personalizado, suas fotos identificadas automaticamente por IA, e um convite para a próxima edição. O organizador recebe relatórios completos para tomar decisões melhores.

6.1 Entregáveis da Fase 4
Fluxo de homologação de resultados com correção manual e auditoria

Publicação de resultados com ranking geral, por categoria, sexo e faixa etária

Exportação em PDF, CSV e formato CBAT

Geração automática de certificados digitais em lote (PDFs personalizados)

QR Code de autenticidade no certificado com página de validação

Compartilhamento de certificado em Instagram, WhatsApp e LinkedIn

Upload de fotos em lote pelos fotógrafos credenciados

Reconhecimento de dorsal por IA (Google Vision API ou AWS Rekognition)

Galeria personalizada por dorsal com notificação ao atleta

Pesquisa NPS automática 24h após o evento

Dashboard NPS com segmentação (promotores/neutros/detratores)

Relatório financeiro completo por evento

Relatório operacional (inscritos vs presentes, DNS/DNF, ocorrências)

Relatório histórico comparativo entre edições

E-mail de convite antecipado para atletas da edição atual

6.2 Sprints da Fase 4

Sprint 17

Resultados e Certificados

Fluxo de homologação com aprovação, correção e log de auditoria

Publicação de resultados com todos os filtros (categoria, sexo, faixa etária)

Geração de certificados PDF em lote com Prawn (Ruby gem)

Template de certificado personalizado por evento (logo, cores)

QR Code de autenticidade com página de validação online

Botões de compartilhamento: Instagram, WhatsApp, LinkedIn

2 semanas

Sprint 18

Galeria de Fotos com IA

Sistema de upload em lote para fotógrafos credenciados (Active Storage)

Integração com Google Vision API para OCR de dorsais nas fotos

Job assíncrono (Sidekiq) para processar e associar fotos por dorsal

Galeria pública: atleta busca pelo número e vê suas fotos

Notificação automática ao atleta quando fotos ficam disponíveis

Suporte a download gratuito ou pago (integração com Mercado Pago)

2 semanas

Sprint 19

NPS, Relatórios e Engajamento

Pesquisa NPS enviada automaticamente 24h após o evento

Dashboard NPS com gráficos (nota geral, por dimensão, histórico)

Segmentação automática: promotores recebem convite de indicação

Relatório financeiro: receita por lote, custo por atleta, margem

Relatório operacional: presença, DNS/DNF, ocorrências

Relatório histórico com comparativo entre edições

2 semanas

6.3 Critérios de aceite da Fase 4

#

Critério

Como verificar

FA4-01

Certificados gerados em lote para 2.000 atletas em menos de 5 minutos

Teste de performance com job Sidekiq e 2.000 registros

FA4-02

IA identifica corretamente >= 85% dos dorsais nas fotos de teste

Teste com batch de 200 fotos com dorsais conhecidos

FA4-03

E-mail do NPS disparado automaticamente 24h após o horário de encerramento

Teste com Timecop + verificação de e-mail enviado

FA4-04

Relatório financeiro exibe receita com diferença menor que R$ 0,01 vs soma real

Teste de reconciliação com dados de fixture

FA4-05

Compartilhamento de certificado gera link válido com preview correto

Teste com Open Graph validator

7. Fase 5 — Otimização e Escala

F5

Otimização e Escala

Mês 12 | Sprint 20

Objetivo: preparar o sistema para operação em produção com múltiplos eventos simultâneos, alta concorrência na abertura de inscrições, observabilidade completa e features avançadas que elevam a qualidade do produto.

7.1 Entregáveis da Fase 5
Otimização de queries N+1 (Bullet gem + índices adicionais)

Filas de espera controladas para abertura de lotes (rate limiting + queue)

Observabilidade: Sentry (erros) + Datadog ou AppSignal (performance APM)

Cache estratégico com Redis (ranking, resultados publicados, site do evento)

Exportação CBAT para Confederação Brasileira de Atletismo

Multi-evento: um organizador gerencia múltiplas corridas simultâneas

API pública para parceiros (cronometragem, apps de corrida)

Documentação técnica completa (API, deploy, runbooks)

Pentest básico e revisão de segurança LGPD

Plano de disaster recovery e runbook de incidentes

7.2 Sprint 20 — Otimização Final

Sprint 20

Otimização, Segurança e Lançamento

Profiling e eliminação de queries N+1 com Bullet + explain analyze

Cache de ranking e resultados com Redis (TTL 10s no ranking ao vivo)

Rate limiting na abertura de inscrições (Rack::Attack)

Setup Sentry (error tracking) e AppSignal (APM)

Exportação CBAT e documentação da API pública

Pentest, revisão LGPD e documentação de runbooks

2 semanas

8. Governança e Processo

8.1 Cerimônias ágeis
Cerimônia

Descrição

Frequência

Sprint Planning

Definição das tasks da sprint, estimativa em story points e alinhamento de prioridades com o cliente

A cada 2 semanas (início da sprint)

Daily Standup

Sincronização diária de 15 minutos: o que fez, o que fará e impedimentos

Diária (assíncrona em texto se remoto)

Sprint Review

Demonstração das funcionalidades entregues para o cliente com feedback estruturado

A cada 2 semanas (final da sprint)

Sprint Retrospectiva

Revisão interna do processo: o que funcionou, o que melhorar e ações concretas

A cada 2 semanas (após a review)

Reunião de Fase

Revisão do roadmap, repriorização e alinhamento estratégico ao final de cada fase

A cada 2 meses

8.2 Definição de pronto (Definition of Done)
Uma história de usuário é considerada concluída quando TODOS os itens abaixo forem atendidos:

Código revisado por pelo menos um outro desenvolvedor (Pull Request aprovado)

Testes unitários e de integração escritos e passando (cobertura não regride)

Pipeline CI/CD verde (lint, testes, build, deploy para staging)

Funcionalidade demonstrada e aprovada em ambiente de staging pelo cliente

Documentação de código atualizada (comentários, README ou wiki)

Nenhum erro novo no Sentry após deploy em staging

8.3 Gestão de riscos
Risco

Impacto

Probabilidade

Mitigação

Integração do gateway de pagamento com falhas

Alto — inscrições paradas

Média

Ambiente sandbox completo antes do go-live; fallback para boleto

App de check-in sem internet no dia

Alto — check-in manual

Alta

Modo offline obrigatório com SQLite local; teste de campo antes do evento

Fornecedor de cronometragem sem API

Médio — ranking atrasado

Baixa

Importador de CSV como fallback; suporte a entrada manual

Carga excessiva na abertura de inscrições

Alto — site fora do ar

Alta

Rate limiting, cache agressivo e testes de carga antes de cada abertura

Mudança de escopo no meio do desenvolvimento

Médio — prazo estourado

Média

Reuniões de fase para repriorização; backlog bem definido

8.4 Papéis e responsabilidades
Papel

Responsabilidades

Perfil sugerido

Product Owner (PO)

Priorização do backlog, aceite de funcionalidades, alinhamento com stakeholders

Sócio ou gerente de produto da empresa

Tech Lead

Arquitetura técnica, revisão de código, decisões de stack e padrões

Desenvolvedor Rails sênior >= 5 anos

Desenvolvedor Full-stack

Implementação de features front-end e back-end, testes

2–3 devs Rails plenos

QA / Tester

Testes manuais exploratórios, casos de borda, homologação de sprints

1 QA com experiência em Rails/Capybara

DevOps / Infra

Pipeline CI/CD, infraestrutura, monitoramento e segurança

1 DevOps (pode ser part-time)

9. Métricas de Qualidade e Metas

Métrica

Meta Mínima

Meta Ideal

Ferramenta

Cobertura de testes (SimpleCov)

80%

90%

SimpleCov + RSpec

Tempo de resposta (p95)

< 500ms

< 200ms

AppSignal / Datadog

Uptime mensal

99,5%

99,9%

UptimeRobot + Heroku Metrics

Erros em produção

< 0,1% das requisições

< 0,01%

Sentry

Score Lighthouse (performance)

85

95

CI com Lighthouse CI

Score Lighthouse (acessibilidade)

80

90

CI com Lighthouse CI

Abertura de e-mail transacional

30%

50%

SendGrid Dashboard

Falsos negativos no OCR de dorsais

< 15%

< 5%

Monitoramento manual pós-evento

10. Checklist de Setup Inicial

Antes de iniciar a Sprint 1, os seguintes itens devem estar configurados e validados:

10.1 Infraestrutura e ambiente
Repositório GitHub criado com branch protection em main e develop

Ambientes configurados: development, staging e production

PostgreSQL 16 provisionado (local via Docker + staging/prod no serviço gerenciado)

Redis 7 provisionado para cache e filas Sidekiq

Active Storage configurado com bucket S3 ou Cloudflare R2

Pipeline CI/CD no GitHub Actions: lint (RuboCop) + RSpec + deploy automático para staging

Sentry configurado com DSN para rastreamento de erros

Variáveis de ambiente documentadas no .env.example

10.2 Contas e credenciais
Conta Mercado Pago com acesso à API (credenciais sandbox e produção)

Conta SendGrid com domínio verificado para envio de e-mails

Conta Mapbox com token de acesso para mapas

Conta Google Cloud ou AWS para API de reconhecimento de imagens (Fase 4)

Domínio registrado e SSL configurado

Fim do Plano de Desenvolvimento — v1.0 — Junho de 20

---

[← Voltar ao README](../README.md)
