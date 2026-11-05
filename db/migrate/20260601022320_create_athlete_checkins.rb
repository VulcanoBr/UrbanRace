class CreateAthleteCheckins < ActiveRecord::Migration[8.1]
  def change
    create_table :athlete_checkins do |t|
      t.references :registration, null: false, foreign_key: true
      t.references :volunteer_station, null: false, foreign_key: true
      t.datetime :realizado_em
      t.boolean :offline
      t.boolean :sincronizado

      t.timestamps
    end
  end
end
