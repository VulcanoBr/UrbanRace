class CreateIncidents < ActiveRecord::Migration[8.1]
  def change
    create_table :incidents do |t|
      t.references :event, null: false, foreign_key: true
      t.references :registration, null: false, foreign_key: true
      t.references :organizer, null: false, foreign_key: true
      t.string :tipo
      t.string :gravidade
      t.decimal :km_local, precision: 10, scale: 2, null: false
      t.datetime :ocorrida_em
      t.text :descricao
      t.string :status

      t.timestamps
    end
  end
end
