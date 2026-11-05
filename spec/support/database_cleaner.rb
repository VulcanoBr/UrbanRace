# frozen_string_literal: true

RSpec.configure do |config|
  config.before(:suite) do
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with(:truncation)
  end

  config.around(:each) do |example|
    DatabaseCleaner.cleaning do
      example.run
    end
  end

  

  # Specs com JS (Capybara) precisam de truncation (transações não funcionam cross-process)
  config.before(:each, :js) do
    DatabaseCleaner.strategy = :truncation
  end

  config.after(:each, :js) do
    DatabaseCleaner.strategy = :transaction
  end
end
