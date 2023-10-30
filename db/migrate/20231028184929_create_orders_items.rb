class CreateOrdersItems < ActiveRecord::Migration[7.0]
  def change
    create_table :orders_items do |t|
      t.references :product, null: false, foreign_key: true
      t.references :order, null: false, foreign_key: true
      t.references :currency, null: false, foreign_key: true
      t.decimal :price_without_tax, null: false, precision: 24, scale: 3
      t.decimal :price, null: false, precision: 24, scale: 3
      t.integer :quantity, null: false, precision: 24, scale: 3
      t.decimal :subtotal, null: false, precision: 24, scale: 3
      t.decimal :tax_amount, null: false, precision: 24, scale: 3
      t.decimal :total, null: false, precision: 24, scale: 3
      t.timestamps
    end
  end
end
