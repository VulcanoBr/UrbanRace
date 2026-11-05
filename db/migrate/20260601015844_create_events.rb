class CreateEvents < ActiveRecord::Migration[8.1]
  def change
    create_table :events do |t|
      t.references :organizer, null: false, foreign_key: true
      t.string :nome
      t.date :data_largada
      t.time :horario_largada
      t.string :local_partida
      t.string :cidade
      t.string :estado
      t.string :slug_url
      t.string :status
      t.text :descricao
      t.text :kit_descricao
      t.text :cronograma
      t.string :instagram_url
      t.string :whatsapp_contato
      t.integer :limite_atletas
      t.text :cancellation_reason

      t.timestamps
    end
    add_index :events, :slug_url
  end
end
