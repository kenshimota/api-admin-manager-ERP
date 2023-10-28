class CreateCustomersPhones < ActiveRecord::Migration[7.0]
  def change
    create_table :customers_phones do |t|
      t.references :customer, null: false, foreign_key: true
      t.references :phone, null: false, foreign_key: true
      t.timestamps
    end

    add_index :customers_phones, [:customer_id, :phone_id], unique: true
  end
end
