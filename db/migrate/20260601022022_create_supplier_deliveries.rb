class CreateSupplierDeliveries < ActiveRecord::Migration[8.1]
  def change
    create_table :supplier_deliveries do |t|
      t.references :supplier_contract, null: false, foreign_key: true
      t.string :descricao
      t.date :data_prevista
      t.date :data_real
      t.string :status
      t.text :observacao

      t.timestamps
    end
  end
end
