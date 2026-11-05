class CreateVolunteerShifts < ActiveRecord::Migration[8.1]
  def change
    create_table :volunteer_shifts do |t|
      t.references :volunteer_station, null: false, foreign_key: true
      t.references :volunteer, null: false, foreign_key: true
      t.string :turno
      t.string :status
      t.datetime :checkin_em

      t.timestamps
    end
  end
end
