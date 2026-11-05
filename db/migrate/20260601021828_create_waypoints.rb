class CreateWaypoints < ActiveRecord::Migration[8.1]
  def change
    create_table :waypoints do |t|
      t.references :route, null: false, foreign_key: true
      t.string :nome
      t.decimal :km, precision: 10, scale: 2, null: false
      t.boolean :eh_chegada
      t.boolean :eh_largada
      t.datetime :closed_at
      t.integer :closed_by_id

      t.timestamps
    end
  end
end
