class CreateProducts < ActiveRecord::Migration[7.0]
  def change
    create_table :products do |t|
      t.string :name, null: false
      t.string :code
      t.string :bar_code
      t.integer :stock, default: 0, null: false
      t.integer :reserved, default: 0, null: false
      t.references :tax, null: false, foreign_key: true

      t.timestamps
    end

    add_index :products, :code, unique: true
  end
end
