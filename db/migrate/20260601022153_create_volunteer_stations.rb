class CreateVolunteerStations < ActiveRecord::Migration[8.1]
  def change
    create_table :volunteer_stations do |t|
      t.references :event, null: false, foreign_key: true
      t.references :distance, null: true, foreign_key: true
      t.string :nome
      t.string :tipo
      t.decimal :km_posicao, precision: 10, scale: 2, null: false, default: 0.0
      t.integer :vagas

      t.timestamps
    end
  end
end
