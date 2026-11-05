class CreateEmailCampaigns < ActiveRecord::Migration[8.1]
  def change
    create_table :email_campaigns do |t|
      t.references :event, null: false, foreign_key: true
      t.string :assunto
      t.string :segmento
      t.integer :enviados
      t.integer :abertos
      t.integer :clicados
      t.datetime :enviado_em

      t.timestamps
    end
  end
end
