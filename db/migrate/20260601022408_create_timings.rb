class CreateTimings < ActiveRecord::Migration[8.1]
  def change
    create_table :timings do |t|
      t.references :registration, null: false, foreign_key: true
      t.references :waypoint, null: false, foreign_key: true
      t.datetime :gun_time
      t.datetime :chip_time
      t.integer :posicao_geral
      t.integer :posicao_categoria
      t.decimal :pace_km, precision: 10, scale: 2, null: false

      t.timestamps
    end
    add_index :timings, [:registration_id, :waypoint_id], unique: true
  end
end
