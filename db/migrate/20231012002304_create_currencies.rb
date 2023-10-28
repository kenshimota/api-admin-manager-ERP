class CreateCurrencies < ActiveRecord::Migration[7.0]
  def change
    create_table :currencies do |t|
      t.string :name, null: false
      t.string :code, null: false
      t.string :symbol
      t.decimal :exchange_rate, precision: 22, scale: 3, default: 1, null: false
      t.timestamps
    end

    add_index :currencies, :code, unique: true
  end
end
