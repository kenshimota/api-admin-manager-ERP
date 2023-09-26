class CreateWarehouses < ActiveRecord::Migration[7.0]
  def change
    create_table :warehouses do |t|
      t.string :name, null: false
      t.string :address

      t.timestamps
    end
    add_index :warehouses, :name, unique: true
  end
end
