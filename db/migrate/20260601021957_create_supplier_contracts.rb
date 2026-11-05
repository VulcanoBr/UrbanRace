class CreateSupplierContracts < ActiveRecord::Migration[8.1]
  def change
    create_table :supplier_contracts do |t|
      t.references :supplier, null: false, foreign_key: true
      t.references :event, null: false, foreign_key: true
      t.decimal :valor, precision: 10, scale: 2, null: false, default: 0.0
      t.string :status
      t.string :arquivo_pdf
      t.datetime :assinado_em

      t.timestamps
    end
  end
end
