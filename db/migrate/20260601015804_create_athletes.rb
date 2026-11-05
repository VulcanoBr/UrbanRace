class CreateAthletes < ActiveRecord::Migration[8.1]
  def change
    create_table :athletes do |t|
      t.string :email_address, null: false
      t.string :password_digest, null: false
      t.string :nome
      t.string :cpf
      t.date :nascimento
      t.string :sexo
      t.string :telefone

      t.timestamps
    end
    add_index :athletes, :email_address, unique: true
    add_index :athletes, :cpf, unique: true
  end
end
