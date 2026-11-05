# lib/tasks/db_reset_all.rake
namespace :db do
  desc "Drop, create, migrate (primary) e schema:load (queue) de todos os bancos"
  task reset_all: :environment do
    puts "🗑  Dropando bancos..."
    system("bin/rails db:drop") || abort("Falha ao dropar bancos")

    puts "🆕 Criando bancos..."
    system("bin/rails db:create") || abort("Falha ao criar bancos")

    puts "⬆️  Rodando migrations do banco primary..."
    system("bin/rails db:migrate") || abort("Falha ao migrar banco primary")

    puts "📦 Carregando schema do banco queue (Solid Queue)..."
    system("bin/rails db:schema:load:queue") || abort("Falha ao carregar schema do banco queue")

    puts "✅ Bancos urban_race e urban_race_queue prontos!"
  end
end