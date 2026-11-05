class CreatePendingTransfers < ActiveRecord::Migration[8.1]
  def change
    create_table :pending_transfers do |t|
      t.references :transfer,    null: false, foreign_key: true
      t.references :registration, null: false, foreign_key: true
      t.string     :email_destino, null: false
      t.string     :status,        null: false, default: "aguardando"
      # status: aguardando | aceito | expirado | cancelado
      t.string :token
      t.string :cpf_destino
      t.datetime   :expira_em,    null: false

      t.timestamps
    end

    add_index :pending_transfers, :status
    add_index :pending_transfers, :expira_em
  end
end