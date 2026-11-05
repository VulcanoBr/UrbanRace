class CreateCoupons < ActiveRecord::Migration[8.1]
  def change
    create_table :coupons do |t|
      t.references :event, null: false, foreign_key: true
      t.references :distance, null: true, foreign_key: true
      t.references :category, null: true, foreign_key: true
      t.string :codigo
      t.string :tipo
      t.decimal :valor, precision: 10, scale: 2, null: false
      t.integer :uso_maximo
      t.integer :uso_atual
      t.datetime :validade

      t.timestamps
    end
    add_index :coupons, :codigo, unique: true
    add_index :coupons, [:event_id, :codigo], unique: true
  end
end
