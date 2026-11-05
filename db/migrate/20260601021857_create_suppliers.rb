class CreateSuppliers < ActiveRecord::Migration[8.1]
  def change
    create_table :suppliers do |t|
      t.string :razao_social
      t.string :cnpj
      t.string :contato
      t.string :email_contato
      t.string :phone_contato
      t.string :tipo_servico
      t.decimal :avaliacao_media, precision: 10, scale: 2, null: false, default: 0.0

      t.timestamps
    end
    add_index :suppliers, :cnpj
  end
end
