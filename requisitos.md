[← Voltar ao README](../README.md)

---

DOCUMENTO DE REQUISITOS

Sistema de Gestão de Corridas de Rua

Versão 1.0 | Maio de 2026

Confidencial — uso interno

1. Introdução

1.1 Objetivo
Este documento descreve os requisitos funcionais e não funcionais do Sistema de Gestão de Corridas de Rua, uma plataforma integrada que suporta todas as etapas do ciclo de vida de eventos: promoção, inscrições, organização logística, execução no dia do evento e pós-evento.

1.2 Escopo
O sistema contempla cinco módulos principais:

Módulo de Promoção — divulgação, marketing digital e funil de conversão

Módulo de Inscrições — cadastro de atletas, pagamentos, kits e vagas

Módulo de Organização — percurso, fornecedores, equipe e licenças

Módulo de Execução — check-in, cronometragem e monitoramento no dia

Módulo de Pós-evento — resultados, certificados, fotos e NPS

1.3 Público-alvo do sistema
Perfil de usuário

Funções no sistema

Organizador / Administrador

Acesso total a todos os módulos, configurações e relatórios

Coordenador de evento

Gerencia organização, equipe, fornecedores e checklist

Voluntário / Operador

App mobile para check-in, gestão de postos e registro de ocorrências

Atleta / Corredor

Portal de inscrição, área do corredor e consulta de resultados

Patrocinador / Parceiro

Painel de visibilidade e relatório de desempenho de cotas

Fotógrafo

Upload de fotos em lote e associação por dorsal

1.4 Definições e siglas
Sigla / Termo

Definição

DNS

Did Not Start — atleta inscrito que não compareceu à largada

DNF

Did Not Finish — atleta que iniciou mas não concluiu a prova

Gun time

Tempo contado desde o disparo oficial da largada

Chip time

Tempo contado desde que o atleta cruzou a linha de largada

Split

Tempo parcial em ponto de passagem intermediário do percurso

Dorsal

Número de identificação do atleta fixado na camiseta

NPS

Net Promoter Score — métrica de satisfação e fidelização

LGPD

Lei Geral de Proteção de Dados — Lei nº 13.709/2018

CBAT

Confederação Brasileira de Atletismo — formato de exportação de resultados

OCR

Reconhecimento Óptico de Caracteres — leitura de dorsais em fotos por IA

2. Visão Geral do Sistema

2.1 Premissas
Plataforma web responsiva (desktop e mobile) e app mobile para voluntários

Suporte a múltiplos eventos simultâneos com isolamento de dados por evento

Integrações com gateways de pagamento nacionais (Pix, cartão, boleto) obrigatórias

Compliance com LGPD em todos os módulos que tratam dados pessoais

Módulo de check-in deve operar em modo offline com sincronização posterior

2.2 Restrições
Cronometragem por chip fornecida por empresa terceirizada; sistema importa via API ou arquivo

Reconhecimento de dorsais em fotos utiliza serviço de IA externo (Google Vision API ou AWS Rekognition)

Relatórios financeiros são complementares e não substituem sistema contábil

3. Módulo de Promoção

Responsável por toda a comunicação pré-evento: criação e gestão do site, campanhas de e-mail marketing, gestão de parceiros e patrocinadores, e análise do funil de conversão.

3.1 Requisitos funcionais
ID

Requisito

Descrição

Prioridade

Módulo

PR-01

Site do evento

Criar e publicar landing page com identidade visual, contador regressivo, mapa do percurso, galeria de edições anteriores, regulamento e CTA para inscrições

Alta

Promoção

PR-02

Gestão de conteúdo (CMS)

Painel administrativo para editar textos, imagens e seções do site sem necessidade de programação

Alta

Promoção

PR-03

Contador regressivo

Exibir contagem regressiva até a largada atualizando por dia, hora, minuto e segundo

Alta

Promoção

PR-04

Mapa interativo do percurso

Exibir percurso em mapa interativo com marcadores de largada, chegada, hidratação e postos médicos

Alta

Promoção

PR-05

Calendário editorial

Planejar e agendar posts em Instagram, Facebook e TikTok com data, canal e status

Média

Promoção

PR-06

Integração Meta Ads

Registrar campanhas pagas associando-as ao evento para rastreamento de custo por inscrição

Média

Promoção

PR-07

E-mail marketing

Criar e enviar sequências de e-mail segmentadas por perfil do corredor com templates personalizáveis

Alta

Promoção

PR-08

Alertas de lote

Disparar e-mail e notificação automática em mudança de lote ou quando restarem menos de 10% das vagas

Alta

Promoção

PR-09

Cadastro de patrocinadores

Cadastrar patrocinadores com cota (ouro/prata/bronze), valor e benefícios contratados

Alta

Promoção

PR-10

Links de indicação rastreáveis

Gerar links por parceiro/influenciador para medir inscrições originadas de cada canal

Média

Promoção

PR-11

Relatório de patrocinadores

Gerar relatório de visibilidade com impressões estimadas e inscrições atribuídas

Média

Promoção

PR-12

Analytics do funil

Painel com visitas por canal, taxa de conversão e custo por inscrição por canal

Alta

Promoção

3.2 Casos de uso
ID

Ator

Ação do usuário

Resultado esperado

CU-PR-01

Organizador

Configura o site com logo, datas e percurso

Site publicado e acessível em URL customizada

CU-PR-02

Organizador

Agenda sequência de e-mails de lançamento

E-mails disparados automaticamente nas datas configuradas

CU-PR-03

Parceiro

Acessa link de indicação e compartilha nas redes

Inscrições originadas registradas e atribuídas ao parceiro

CU-PR-04

Organizador

Consulta analytics após campanha paga

Painel exibe CPI, conversão e comparativo com edição anterior

4. Módulo de Inscrições

Gerencia o processo completo de inscrição: formulário, pagamento, controle de vagas por categoria, gestão de kits e dorsais, transferência de vaga e comunicações automáticas pré-evento.

4.1 Requisitos funcionais
ID

Requisito

Descrição

Prioridade

Módulo

IN-01

Formulário de inscrição

Formulário responsivo com dados pessoais, contato de emergência, categoria, distância, tamanho de camiseta e aceite de regulamento

Alta

Inscrições

IN-02

Upload de atestado médico

Permitir upload de PDF ou imagem do atestado com validação de formato e tamanho máximo de 5 MB

Alta

Inscrições

IN-03

Aceite LGPD

Termo de consentimento com aceite obrigatório, registrando data, hora e IP

Alta

Inscrições

IN-04

Lotes de preço progressivos

Configurar lotes com preço, data de início/encerramento e limite de vagas; virada automática sem intervenção manual

Alta

Inscrições

IN-05

Pagamento — Pix

QR Code Pix com confirmação automática em até 5 minutos

Alta

Inscrições

IN-06

Pagamento — Cartão

Cartão de crédito em até 6 vezes e débito, com feedback imediato de aprovação

Alta

Inscrições

IN-07

Pagamento — Boleto

Boleto com vencimento configurável; vagas reservadas por até 3 dias úteis

Média

Inscrições

IN-08

Cupom de desconto

Criar cupons com limite de uso, validade e restrição por categoria

Média

Inscrições

IN-09

Controle de vagas

Limite por categoria e distância com bloqueio automático ao atingir o limite

Alta

Inscrições

IN-10

Lista de espera

Ao esgotar vagas, oferecer lista de espera com notificação automática quando vaga abrir

Alta

Inscrições

IN-11

Transferência de vaga

Atleta transfere vaga para outra pessoa dentro do prazo definido, com taxa opcional

Alta

Inscrições

IN-12

Migração de categoria

Solicitação de mudança de categoria sujeita a aprovação e diferença de valor

Média

Inscrições

IN-13

Geração de dorsal

Atribuição automática de número de dorsal após confirmação do pagamento

Alta

Inscrições

IN-14

QR Code do atleta

QR Code único por atleta para check-in e retirada do kit, com hash de segurança

Alta

Inscrições

IN-15

Agendamento de retirada

Slots de horário para retirada do kit na expo com limite por janela de tempo

Média

Inscrições

IN-16

Área do corredor

Portal autenticado com comprovante, QR Code, dorsal, horário de retirada e opção de transferência

Alta

Inscrições

IN-17

E-mail de confirmação

E-mail automático com comprovante, dorsal e link da área do corredor após confirmação

Alta

Inscrições

IN-18

Lembrete de retirada de kit

E-mail e push 48h e 24h antes da expo com horário agendado e endereço

Alta

Inscrições

IN-19

Reembolso e cancelamento

Cancelamento com regras de reembolso configuráveis por prazo; integração com gateway para estorno

Alta

Inscrições

IN-20

Painel de inscrições

Lista de inscritos com filtros por categoria/status/pagamento, exportação CSV/Excel e indicadores de ocupação

Alta

Inscrições

4.2 Casos de uso
ID

Ator

Ação do usuário

Resultado esperado

CU-IN-01

Atleta

Acessa formulário, escolhe 10k e conclui pagamento via Pix

Inscrição confirmada, dorsal gerado, e-mail enviado em até 5 minutos

CU-IN-02

Atleta

Tenta se inscrever com categoria esgotada

Sistema oferece lista de espera; atleta notificado quando vaga abre

CU-IN-03

Atleta

Solicita transferência de vaga 10 dias antes

Transferência processada com nova associação e confirmação para ambos

CU-IN-04

Organizador

Abre lote 2 manualmente antes do prazo

Preço atualizado no site e alertas enviados imediatamente

CU-IN-05

Organizador

Exporta lista de inscritos com dados de kit

Arquivo CSV com nome, tamanho de camiseta, categoria e dorsal

5. Módulo de Organização

Centraliza o planejamento logístico: percurso, gestão de fornecedores, escala de voluntários, controle de licenças e checklist operacional por linha do tempo.

5.1 Requisitos funcionais
ID

Requisito

Descrição

Prioridade

Módulo

OR-01

Mapa do percurso

Criar e editar percurso em mapa interativo com marcação de largada, chegada, km, hidratação e postos médicos

Alta

Organização

OR-02

Múltiplas distâncias

Suportar percursos independentes por distância (5k, 10k, 21k, 42k) no mesmo evento

Alta

Organização

OR-03

Exportar mapa para atletas

Gerar versão pública do mapa para site e compartilhamento

Alta

Organização

OR-04

Cadastro de fornecedores

Cadastrar fornecedores com CNPJ, contato, tipo de serviço e histórico de avaliações

Alta

Organização

OR-05

Orçamentos e contratos

Registrar propostas por fornecedor, marcar proposta vencedora e anexar contrato (PDF)

Alta

Organização

OR-06

Controle de entrega

Marcos de entrega com data prevista e status; alertar quando prazo estiver em risco

Alta

Organização

OR-07

Registro de ocorrências

Registrar não conformidades com prazo de resolução e responsável; reabrir até resolução

Alta

Organização

OR-08

Controle de pagamentos a fornecedores

Pagamentos com status, anexo de NF e comprovante

Alta

Organização

OR-09

Avaliação de fornecedor

Nota pós-evento por critério (prazo, qualidade, atendimento) para histórico

Média

Organização

OR-10

Cadastro de voluntários

Cadastrar voluntários com contato, disponibilidade, função e histórico

Alta

Organização

OR-11

Escala de voluntários

Criar postos com número de vagas e turno; associar voluntários com confirmação por e-mail

Alta

Organização

OR-12

Check-in de voluntários

App mobile para presença do voluntário no posto com registro de horário

Alta

Organização

OR-13

Controle de licenças

Documentos exigidos com prazo e status (pendente/aprovado/vencido)

Alta

Organização

OR-14

Alertas de prazo

Alertar 30, 15 e 7 dias antes para documentos com aprovação pendente

Alta

Organização

OR-15

Checklist operacional

Tarefas por fase (90 dias, 30 dias, 7 dias, dia do evento) com responsável e status

Alta

Organização

OR-16

Painel de status do evento

Visão consolidada com semáforo por área (percurso, fornecedores, licenças, inscrições)

Alta

Organização

5.2 Casos de uso
ID

Ator

Ação do usuário

Resultado esperado

CU-OR-01

Coordenador

Cria percurso de 10k com pontos de hidratação e posto médico

Mapa salvo, publicado no site e disponível para briefing

CU-OR-02

Coordenador

Registra que medalhas do fornecedor X não chegaram 5 dias antes

Ocorrência criada, responsável notificado e prazo definido

CU-OR-03

Coordenador

Consulta escala do posto de hidratação km 3

Lista exibe nome, contato e status de confirmação de cada voluntário

CU-OR-04

Administrador

Acessa painel de status 2 semanas antes

Licença de trânsito em vermelho (pendente); demais áreas em verde

6. Módulo de Execução

Opera no dia do evento: credenciamento, cronometragem, monitoramento em tempo real, comunicação entre equipes e gestão de ocorrências médicas e operacionais.

6.1 Requisitos funcionais
ID

Requisito

Descrição

Prioridade

Módulo

EX-01

Check-in por QR Code

App mobile lê QR Code do atleta com validação instantânea da inscrição

Alta

Execução

EX-02

Modo offline do check-in

Operação sem internet por no mínimo 8h; sincronização automática ao reconectar

Alta

Execução

EX-03

Associação chip-atleta

Registrar associação dorsal-chip-atleta no check-in com confirmação por leitura do chip

Alta

Execução

EX-04

Painel de presença

Percentual de credenciados por categoria em tempo real com alerta 30min antes da largada

Alta

Execução

EX-05

Registro de gun time

Registrar horário exato da largada; suportar múltiplas ondas com horários independentes

Alta

Execução

EX-06

Importação de chip time

Importar via API ou arquivo os tempos registrados pelo sistema de cronometragem terceirizado

Alta

Execução

EX-07

Splits por ponto

Registrar e exibir tempos parciais de cada atleta nos pontos de passagem

Alta

Execução

EX-08

Ranking em tempo real

Ranking provisório atualizado automaticamente com filtros por categoria e sexo

Alta

Execução

EX-09

Detecção de DNF e DNS

Identificar automaticamente DNS e DNF notificando a equipe responsável

Alta

Execução

EX-10

Painel público de tracking

Página web onde familiares consultam posição e splits pelo dorsal sem login

Média

Execução

EX-11

Comunicação por setor

Chat interno por posto e broadcast geral para coordenação no percurso

Alta

Execução

EX-12

Registro de ocorrência médica

Registrar ocorrência com km, horário e gravidade; acionar ambulância e contato de emergência

Alta

Execução

EX-13

Solicitação de recurso

Voluntários solicitam reabastecimento de água/material via app com visibilidade da coordenação

Média

Execução

EX-14

Encerramento do percurso

Fluxo de encerramento com confirmação do último atleta e liberação dos resultados preliminares

Alta

Execução

EX-15

Premiação e pódio

Registrar atletas premiados por categoria; gerar lista de pódio para cerimônia

Alta

Execução

6.2 Casos de uso
ID

Ator

Ação do usuário

Resultado esperado

CU-EX-01

Voluntário

Check-in de atleta sem conexão à internet

Registrado localmente; sincronizado ao servidor quando internet voltar

CU-EX-02

Coordenador

Dispara largada e registra gun time

Contagem iniciada; ondas subsequentes com horários individuais

CU-EX-03

Familiar

Acessa painel público e busca dorsal 1523

Posição e splits do atleta exibidos em tempo real

CU-EX-04

Voluntário

Registra ocorrência médica no km 8 às 08h42

Ambulância mais próxima notificada; contato de emergência acionado

CU-EX-05

Coordenador

Confirma chegada do último atleta

Resultados preliminares liberados; DNS e DNF consolidados

7. Módulo de Pós-evento

Gerencia atividades após a corrida: resultados oficiais, certificados digitais, galeria de fotos, pesquisa NPS e relatórios de gestão para subsidiar a próxima edição.

7.1 Requisitos funcionais
ID

Requisito

Descrição

Prioridade

Módulo

PE-01

Homologação de resultados

Fluxo de revisão com correção manual antes da publicação oficial e registro de alterações

Alta

Pós-evento

PE-02

Publicação de resultados

Ranking geral e por categoria/sexo/faixa etária; página individual com tempo, posição e splits

Alta

Pós-evento

PE-03

Exportação de resultados

Exportar em PDF, CSV e formato CBAT para submissão à confederação

Alta

Pós-evento

PE-04

Notificação de resultado

E-mail automático ao atleta com resultado, link da página individual e botão de compartilhamento

Alta

Pós-evento

PE-05

Certificado digital

PDF personalizado com nome, tempo, categoria, posição e identidade visual do evento

Alta

Pós-evento

PE-06

QR Code no certificado

QR Code de autenticidade apontando para página de validação online

Média

Pós-evento

PE-07

Compartilhamento do certificado

Compartilhamento direto em Instagram, WhatsApp e LinkedIn

Alta

Pós-evento

PE-08

Upload de fotos em lote

Fotógrafos credenciados fazem upload em lote associado ao evento e setor do percurso

Alta

Pós-evento

PE-09

Reconhecimento de dorsal por IA

Processar fotos com OCR/IA para associar automaticamente cada foto ao atleta

Alta

Pós-evento

PE-10

Busca de fotos por dorsal

Atleta pesquisa fotos pelo dorsal e visualiza galeria personalizada

Alta

Pós-evento

PE-11

Notificação de fotos

E-mail ao atleta quando suas fotos estiverem disponíveis

Alta

Pós-evento

PE-12

Download de fotos

Download gratuito ou pago configurável; integração com gateway para fotos pagas

Média

Pós-evento

PE-13

Pesquisa NPS

E-mail automático 24h após o evento com nota 0–10, dimensões e campo livre

Alta

Pós-evento

PE-14

Dashboard NPS

Resultado do NPS, médias por dimensão, nuvem de palavras e histórico por edição

Alta

Pós-evento

PE-15

Segmentação por NPS

Promotores recebem convite de indicação; detratores recebem acompanhamento personalizado

Média

Pós-evento

PE-16

Relatório financeiro

Receita por lote, despesas por fornecedor, custo por atleta, margem e comparativo com meta

Alta

Pós-evento

PE-17

Relatório operacional

Inscritos vs presentes, DNS/DNF, ocorrências médicas e avaliação de fornecedores

Alta

Pós-evento

PE-18

Relatório histórico

Comparativo entre edições: inscritos, NPS, receita, taxa de retorno e canais de conversão

Alta

Pós-evento

PE-19

Convite antecipado

Abertura antecipada de inscrições para atletas da edição atual com desconto ou acesso prioritário

Média

Pós-evento

7.2 Casos de uso
ID

Ator

Ação do usuário

Resultado esperado

CU-PE-01

Organizador

Homologa e publica os resultados

Ranking oficial disponível; e-mails disparados para todos os atletas

CU-PE-02

Atleta

Baixa certificado digital na área do corredor

PDF gerado com dados personalizados e QR Code de autenticidade

CU-PE-03

Fotógrafo

Faz upload de 3.000 fotos pelo painel

IA associa cada foto ao dorsal; atletas notificados por e-mail

CU-PE-04

Atleta

Busca fotos digitando o dorsal 1523

Galeria exibe apenas as fotos do atleta para visualização e download

CU-PE-05

Organizador

Consulta dashboard NPS 48h após o evento

NPS e médias por dimensão exibidos com comparativo da edição anterior

CU-PE-06

Organizador

Gera relatório financeiro da edição

Receita por lote, custo por atleta, margem e comparativo com orçamento

8. Requisitos Não Funcionais

8.1 Desempenho
ID

Requisito

Descrição

Prioridade

Módulo

NF-01

Tempo de resposta

Páginas carregam em menos de 2s em 4G; API responde em menos de 500ms para 95% das requisições

Alta

Todos

NF-02

Carga simultânea

Suportar 5.000 usuários simultâneos sem degradação, especialmente na abertura de lotes

Alta

Inscrições

NF-03

Check-in offline

App opera sem internet por no mínimo 8 horas com sincronização em segundo plano

Alta

Execução

NF-04

Ranking em tempo real

Atualização em até 10 segundos após leitura do chip

Alta

Execução

8.2 Segurança e conformidade
ID

Requisito

Descrição

Prioridade

Módulo

NF-05

LGPD

Dados pessoais coletados com consentimento, armazenados criptografados e disponíveis para exclusão a pedido

Alta

Todos

NF-06

Autenticação 2FA

Acesso administrativo com dois fatores; senhas com hash bcrypt ou Argon2

Alta

Todos

NF-07

HTTPS/TLS

Toda comunicação criptografada via TLS 1.2 ou superior

Alta

Todos

NF-08

Log de auditoria

Registrar todas as ações administrativas (quem, o quê, quando, IP) com retenção de 1 ano

Alta

Todos

NF-09

PCI DSS

Processamento de pagamentos em conformidade com PCI DSS; dados de cartão não transitam pelos servidores

Alta

Inscrições

8.3 Usabilidade e disponibilidade
ID

Requisito

Descrição

Prioridade

Módulo

NF-10

Responsividade

Sistema web plenamente funcional em telas de 360px sem perda de funcionalidade

Alta

Todos

NF-11

Acessibilidade

Páginas públicas atendem WCAG 2.1 nível AA

Média

Promoção

NF-12

Uptime

Disponibilidade mínima de 99,5% ao mês (menos de 4h de indisponibilidade)

Alta

Todos

NF-13

Backup

Backup automático a cada 6h com retenção de 30 dias e teste mensal de restauração

Alta

Todos

NF-14

Escalabilidade

Arquitetura com escalonamento horizontal automático em períodos de pico

Alta

Todos

9. Integrações Externas

Sistema / Serviço

Finalidade

Gateway de pagamento ( Stripe)

Processar Pix, cartão e boleto; confirmar via webhook; processar estornos automaticamente

Google Maps API / Mapbox

Exibir e editar percursos interativos; calcular distâncias e pontos de passagem

Fornecedor de cronometragem (API ou arquivo)

Importar gun time, chip time e splits após cada largada e ponto de passagem

Google Vision API / AWS Rekognition

Reconhecimento de dorsais em fotos para associação automática atleta-foto

Provedor de e-mail transacional (SendGrid / Mailgun)

Envio de e-mails transacionais (confirmação, certificado, resultado) e campanhas segmentadas

Firebase Cloud Messaging / APNs

Push notifications para app mobile de voluntários e atletas

CBAT (exportação)

Geração de arquivo no formato padrão para homologação de resultados na confederação

Meta Ads API (opcional)

Rastreamento de campanhas e importação de métricas de custo para o painel de analytics

10. Critérios de Aceite e Roadmap

10.1 Critérios gerais de aceite
Um requisito será considerado implementado e aceito quando:

Todas as funcionalidades descritas estiverem operacionais em ambiente de produção

Testes funcionais e de regressão passarem sem erros críticos ou bloqueantes

Requisitos não funcionais de desempenho e segurança validados em ambiente de carga

Documentação de usuário disponível para cada módulo

Aprovação formal do responsável pelo produto após demonstração em homologação

10.2 Roadmap de entregas sugerido
Fase

Módulos e funcionalidades prioritárias

Fase 1 — MVP (2–3 meses)

Inscrições: formulário, pagamento Pix/cartão, lotes, painel. Site do evento: CMS básico, contador regressivo, CTA.

Fase 2 — Operação (1–2 meses)

Organização: percurso, fornecedores, checklist, licenças. Execução: check-in offline, gun/chip time, ranking ao vivo.

Fase 3 — Engajamento (1–2 meses)

Promoção: e-mail marketing, analytics do funil. Pós-evento: resultados, certificado digital, NPS, galeria de fotos.

Fase 4 — Otimização

Integrações avançadas (Meta Ads, CBAT), painel público de tracking, reconhecimento de dorsal por IA, app do atleta.

Fim

---

[← Voltar ao README](../README.md)
