class CreateLots < ActiveRecord::Migration[8.1]
  def change
    create_table :lots do |t|
      t.references :distance, null: false, foreign_key: true
      t.integer :numero
      t.decimal :preco, precision: 10, scale: 2, null: false
      t.integer :vagas
      t.datetime :abertura
      t.datetime :encerramento
      t.string :status
      t.text :descricao_kit

      t.timestamps
    end
  end
end
