class CreateSuppliersPhones < ActiveRecord::Migration[7.0]
  def change
    create_table :suppliers_phones do |t|
      t.references :phone, null: false, foreign_key: true
      t.references :supplier, null: false, foreign_key: true

      t.timestamps
    end
    add_index :suppliers_phones, [:phone_id, :supplier_id], unique: true
  end
end
