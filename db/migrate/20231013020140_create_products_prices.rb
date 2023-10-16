class CreateProductsPrices < ActiveRecord::Migration[7.0]
  def change
    create_table :products_prices do |t|
      t.decimal :price, precision: 24, scale: 3, default: 1, null: false
      t.references :product, null: false, foreign_key: true
      t.references :currency, null: false, foreign_key: true
      t.timestamps
    end

    add_index :products_prices, [:product_id, :currency_id], unique: true
  end
end
