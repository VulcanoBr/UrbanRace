class CreateLicenses < ActiveRecord::Migration[8.1]
  def change
    create_table :licenses do |t|
      t.references :event, null: false, foreign_key: true
      t.string :tipo
      t.string :orgao
      t.date :prazo_solicitacao
      t.date :prazo_aprovacao
      t.string :status
      t.string :arquivo_pdf

      t.timestamps
    end
    add_index :licenses, :prazo_aprovacao
  end
end
