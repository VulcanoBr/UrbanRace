class CreateRoutes < ActiveRecord::Migration[8.1]
  def change
    create_table :routes do |t|
      t.references :event, null: false, foreign_key: true
      t.references :distance, null: false, foreign_key: true
      t.jsonb :geojson_traca, default: {}
      t.jsonb :pontos_apoio, default: []

      t.timestamps
    end
    add_index :routes, :geojson_traca, using: :gin
    add_index :routes, [:event_id, :distance_id], unique: true
  end
end
