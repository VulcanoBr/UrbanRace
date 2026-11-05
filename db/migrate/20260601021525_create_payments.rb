class CreatePayments < ActiveRecord::Migration[8.1]
  def change
    create_table :payments do |t|
      t.references :registration, null: false, foreign_key: true
      t.string :metodo, null: false
      t.decimal :valor, precision: 10, scale: 2, null: false
      t.string :status, default: 'pendente'
      t.string :gateway_id
      t.string :gateway_provider
      t.datetime :pago_em
      t.datetime :vencimento

      t.timestamps
    end
    add_index :payments, :gateway_id
  end
end
