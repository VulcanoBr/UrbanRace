class CreatePhotos < ActiveRecord::Migration[8.1]
  def change
    create_table :photos do |t|
      t.references :event, null: false, foreign_key: true
      t.string :url_arquivo
      t.string :fotografo_id
      t.boolean :reconhecido_ia
      t.integer :confianca_ocr
      t.datetime :enviada_em
      t.string :tipo, null: false, default: "atleta"
      t.timestamps
    end
  end
end
