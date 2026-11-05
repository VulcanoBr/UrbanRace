class CreateVolunteers < ActiveRecord::Migration[8.1]
  def change
    create_table :volunteers do |t|
      t.string :nome
      t.string :email
      t.string :telefone
      t.string :funcao_preferida

      t.timestamps
    end
    add_index :volunteers, :email
  end
end
