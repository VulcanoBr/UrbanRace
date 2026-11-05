class CreateCategories < ActiveRecord::Migration[8.1]
  def change
    create_table :categories do |t|
      t.references :distance, null: false, foreign_key: true
      t.string :nome
      t.string :sexo
      t.integer :idade_min
      t.integer :idade_max

      t.timestamps
    end
  end
end
