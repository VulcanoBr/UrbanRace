class CreateSponsorContracts < ActiveRecord::Migration[8.1]
  def change
    create_table :sponsor_contracts do |t|
      t.references :sponsor, null: false, foreign_key: true
      t.references :event, null: false, foreign_key: true
      t.string :cota
      t.string :status
      t.string :arquivo_pdf
      t.datetime :assinado_em
      t.decimal :valor_cota, precision: 10, scale: 2, null: false

      t.timestamps
    end
  end
end
