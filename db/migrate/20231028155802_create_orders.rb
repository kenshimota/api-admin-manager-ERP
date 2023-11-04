class CreateOrders < ActiveRecord::Migration[7.0]
  def change
    create_table :orders do |t|
      t.integer :number
      t.references :user, null: false, foreign_key: true
      t.references :customer, null: false, foreign_key: true
      t.references :orders_status, null: false, foreign_key: true
      t.references :currency, null: false, foreign_key: true
      t.decimal :subtotal, default: 0, null: false, precision: 24, scale: 3
      t.decimal :tax_amount, default: 0, null: false, precision: 24, scale: 3
      t.decimal :total, default: 0, null: false, precision: 24, scale: 3
      t.integer :products_count, default: 0
      t.integer :quantity_total, default: 0
      t.timestamps
    end
    add_index :orders, :number, unique: true
  end
end
