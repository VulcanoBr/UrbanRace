class CreateBroadcastMessages < ActiveRecord::Migration[8.1]
  def change
    create_table :broadcast_messages do |t|
      t.references :event, null: false, foreign_key: true
      t.references :volunteer_station, null: true, foreign_key: true
      
      # Campo 'sender_id' apontando para a tabela 'organizers'
      t.references :sender, null: false, foreign_key: { to_table: :organizers }
      
      t.string :titulo
      t.text :corpo
      t.string :categoria, default: "info"
      t.datetime :sent_at
      t.datetime :lida_em

      t.timestamps
    end
  end
end