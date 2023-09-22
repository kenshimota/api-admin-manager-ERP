class CreateTaxes < ActiveRecord::Migration[7.0]
  def change
    create_table :taxes do |t|
      t.string :name
      t.decimal :percentage, precision: 4, scale: 4, default: 0, null: false
      t.timestamps
    end
    add_index :taxes, :name, unique: true
  end
end