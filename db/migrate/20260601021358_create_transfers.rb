class CreateTransfers < ActiveRecord::Migration[8.1]
  def change
    create_table :transfers do |t|
      t.references :registration, null: false, foreign_key: true
      t.references :athlete_origem, null: false, foreign_key: { to_table: :athletes }
       t.references :athlete_destino, null: true, foreign_key: { to_table: :athletes }
      t.decimal :taxa, precision: 10, scale: 2, null: false, default: 0
      t.string :status
      t.datetime :solicitada_em
      t.datetime :concluida_em
      t.string :token
      t.datetime :token_expira_em
      t.string :email_destino
      t.string :cpf_destino

      t.timestamps
    end

    add_index :transfers, :token,   unique: true
    add_index :transfers, :status
  end
end

