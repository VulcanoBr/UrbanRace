class CreateRegistrations < ActiveRecord::Migration[8.1]
  def change
    create_table :registrations do |t|
      t.references :athlete, null: false, foreign_key: true
      t.references :event, null: false, foreign_key: true
      t.references :distance, null: false, foreign_key: true
      t.references :category, null: false, foreign_key: true
      t.references :lot, null: false, foreign_key: true
      t.string :status
      t.integer :numero_dorsal
      t.string :chip_code
      t.string :tamanho_kit
      t.string :qr_code_hash
      t.datetime :data_inscricao
      t.string :contato_emergencia
      t.string :fone_emergencia
      t.boolean :atestado_enviado
      t.boolean :aceite_lgpd
      t.boolean :kit_entregue
      t.datetime :kit_entregue_em
      t.datetime :lgpd_accepted_at
      t.string :lgpd_accepted_ip

      t.timestamps
    end
    add_index :registrations, :chip_code
    add_index :registrations, :qr_code_hash
    add_index :registrations, [:athlete_id, :event_id], unique: true, where: "status NOT IN ('cancelled', 'transferred')"
    add_index :registrations, [:event_id, :numero_dorsal], unique: true, where: "numero_dorsal IS NOT NULL"
  end
end
