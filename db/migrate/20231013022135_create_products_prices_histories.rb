class CreateProductsPricesHistories < ActiveRecord::Migration[7.0]
  def change
    create_table :products_prices_histories do |t|
      t.references :products_price, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.decimal :price_before, precision: 24, scale: 3, default: 1, null: false
      t.decimal :price_after, precision: 24, scale: 3, default: 1, null: false
      t.timestamps
    end
  end
end
