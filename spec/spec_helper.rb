# frozen_string_literal: true

require "simplecov"

# Gera relatório de cobertura quando a variável de ambiente COVERAGE estiver definida
SimpleCov.start "rails" do
  add_filter "/bin/"
  add_filter "/db/"
  add_filter "/config/"
  add_filter "/spec/"
  add_filter "/test/"
  add_filter "/vendor/"

  add_group "Models",   "app/models"
  add_group "Services", "app/services"
  add_group "Forms",    "app/forms"
  add_group "Jobs",     "app/jobs"
  add_group "Mailers",  "app/mailers"
  add_group "Controllers", "app/controllers"

  minimum_coverage 60
end if ENV["COVERAGE"]

RSpec.configure do |config|
  # Habilita a sintaxe de expectation `expect(x).to` em vez de `x.should`
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  # Configuração de mock framework
  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  # Compartilha o contexto quando metadados correspondentes são usados
  config.shared_context_metadata_behavior = :apply_to_host_groups

  # Permite filtrar specs por tag: rspec --tag focus
  config.filter_run_when_matching :focus

  # Executa em ordem aleatória para evitar dependências entre testes
  config.order = :random
  Kernel.srand config.seed

  # Exibe os 5 exemplos mais lentos
  config.profile_examples = 5

  # Formato padrão de saída
  config.formatter = :progress
end
