class CreateCertificates < ActiveRecord::Migration[8.1]
  def change
    create_table :certificates do |t|
      t.references :result, null: false, foreign_key: true
      t.references :athlete, null: false, foreign_key: true

      t.string :qr_code_hash
      t.datetime :gerado_em

      t.timestamps
    end
    add_index :certificates, :qr_code_hash, unique: true
  end
end
