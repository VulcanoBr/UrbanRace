class CreateDistances < ActiveRecord::Migration[8.1]
  def change
    create_table :distances do |t|
      t.references :event, null: false, foreign_key: true
      t.string :nome
      t.decimal :km, precision: 10, scale: 2, null: false
      t.integer :vagas_total
      t.integer :vagas_ocupadas

      t.timestamps
    end
  end
end
