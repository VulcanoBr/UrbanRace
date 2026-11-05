class CreateNpsResponses < ActiveRecord::Migration[8.1]
  def change
    create_table :nps_responses do |t|
      t.references :athlete, null: false, foreign_key: true
      t.references :event, null: false, foreign_key: true
      t.references :result, null: false, foreign_key: true
      t.integer :nota_geral
      t.integer :nota_percurso
      t.integer :nota_organizacao
      t.integer :nota_estrutura
      t.integer :nota_comunicacao
      t.text :comentario
      t.datetime :respondido_em

      t.timestamps
    end
  end
end
