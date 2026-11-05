class CreateSponsors < ActiveRecord::Migration[8.1]
  def change
    create_table :sponsors do |t|
      #t.references :event, null: false, foreign_key: true
      t.string :nome
      t.string :cnpj
      t.string :contato
      t.string :email_contato
      t.string :phone_contato
      t.string :link_indicacao
      t.string :website
      t.integer :inscricoes_geradas
      t.boolean :ativo

      t.timestamps
    end
  end
end
