class CreateOrganizers < ActiveRecord::Migration[8.1]
  def change
    create_table :organizers do |t|
      t.string :email_address, null: false
      t.string :password_digest, null: false
      t.string :name, null: false
    t.string :role, default: "staff"

      t.timestamps
    end
    add_index :organizers, :email_address, unique: true
  end
end
