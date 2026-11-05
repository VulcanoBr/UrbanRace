# app/jobs/update_lots_status_job.rb
class UpdateLotsStatusJob < ApplicationJob
  queue_as :default

  def perform
    # 1. Fecha lotes ativos que passaram da data de encerramento
    # update_all usa o valor do banco diretamente (string raw)
    Lot.ativo.where("encerramento < ?", Time.current)
       .update_all(status: "inactive")

    # 2. Abre lotes inativos que chegaram na data de abertura
    Lot.inativo
       .where("abertura <= ? AND encerramento > ?", Time.current, Time.current)
       .each do |lot|
         lot.ativo!   # método gerado pelo enum a partir da chave :ativo
       end
  end
end