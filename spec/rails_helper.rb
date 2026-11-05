# frozen_string_literal: true

require "spec_helper"

ENV["RAILS_ENV"] ||= "test"

require File.expand_path("../config/environment", __dir__)

abort("The Rails environment is running in production mode!") if Rails.env.production?

require "rspec/rails"
require "factory_bot_rails"
require "shoulda/matchers"
require "support/auth_helpers"

Dir[Rails.root.join("spec/support/**/*.rb")].sort.each { |f| require f }
# Verifica se as migrações estão atualizadas (sem forçar recriação)
begin
  ActiveRecord::Migration.maintain_test_schema!
rescue ActiveRecord::PendingMigrationError => e
  abort e.to_s.strip
end

RSpec.configure do |config|

  config.fixture_paths = ["#{::Rails.root}/spec/fixtures"]
  config.include FactoryBot::Syntax::Methods

  config.include Rails.application.routes.url_helpers

  config.include AuthHelpers,    type: :controller
  config.include RequestHelpers, type: :request
  config.include AuthHelpers,    type: :request

  config.infer_spec_type_from_file_location!

  config.filter_rails_from_backtrace!

  config.use_transactional_fixtures = true

  config.before(:suite) do
    ActiveJob::Base.queue_adapter = :test
  end

  config.before(:each) do
    ActiveJob::Base.queue_adapter = :test
    ActiveJob::Base.queue_adapter.enqueued_jobs.clear
    ActiveJob::Base.queue_adapter.performed_jobs.clear
  end

  config.before(:each) do
    ActionMailer::Base.deliveries.clear
  end
end

