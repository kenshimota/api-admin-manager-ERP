class CreateInventories < ActiveRecord::Migration[7.0]
  def change
    create_table :inventories do |t|
      t.references :product, null: false, foreign_key: true
      t.integer :stock, null: false, :default => 0
      t.integer :reserved, null: false, :default => 0
      t.references :warehouse, null: false, foreign_key: true
      t.string :observations
      t.timestamps
    end

    add_index :inventories, [:product_id, :warehouse_id], unique: true
  end
end
