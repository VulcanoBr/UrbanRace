class CreatePhotoRegistrations < ActiveRecord::Migration[8.1]
  def change
    # Tabela de junção N:N entre fotos e inscrições (um atleta em várias fotos,
    # uma foto com vários atletas)
    create_table :photo_registrations do |t|
      t.references :photo,        null: false, foreign_key: true
      t.references :registration, null: false, foreign_key: true
      t.integer    :confianca_ocr               # confiança por dorsal nesta foto
      t.boolean    :confirmado_manualmente, null: false, default: false

      t.timestamps
    end

    # Impede duplicata da mesma foto + mesma inscrição
    add_index :photo_registrations,
              [:photo_id, :registration_id],
              unique: true,
              name: :index_photo_registrations_unique

  end
end
