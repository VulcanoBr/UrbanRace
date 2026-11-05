class CreateWaitlists < ActiveRecord::Migration[8.1]
  def change
    create_table :waitlists do |t|
      t.references :event, null: false, foreign_key: true
      t.references :distance, null: false, foreign_key: true
      t.references :category, null: false, foreign_key: true
      t.references :lot, null: false, foreign_key: true
      t.references :athlete, null: false, foreign_key: true
      t.integer :posicao
      t.datetime :data_entrada
      t.string :status

      t.timestamps
    end

    add_index :waitlists, [:athlete_id, :distance_id], unique: true
  end
end
