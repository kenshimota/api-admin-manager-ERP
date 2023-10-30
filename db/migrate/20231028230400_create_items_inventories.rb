class CreateItemsInventories < ActiveRecord::Migration[7.0]
  def change
    create_table :items_inventories do |t|
      t.references :orders_item, null: false, foreign_key: true
      t.references :inventory, null: false, foreign_key: true
      t.integer :quantity, null: false
      t.timestamps
    end
  end
end
