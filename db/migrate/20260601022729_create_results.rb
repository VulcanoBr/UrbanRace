class CreateResults < ActiveRecord::Migration[8.1]
  def change
    create_table :results do |t|
      t.references :registration, null: false, foreign_key: true
      t.references :event, null: false, foreign_key: true
      t.integer :posicao_geral
      t.integer :posicao_categoria
      t.integer :posicao_sexo
      t.integer :posicao_faixa_etaria
      t.string :tempo_bruto
      t.string :tempo_liquido
      t.string :pace_medio
      t.string :status_finalizacao, default: 'concluido'
      t.boolean :homologado, default: false
      t.datetime :homologado_em

      t.timestamps
    end
  end
end
