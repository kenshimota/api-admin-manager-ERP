class CreatePhones < ActiveRecord::Migration[7.0]
  def change
    create_table :phones do |t|
      t.integer :prefix, null: false
      t.bigint :number, null: false
      t.timestamps
    end

    add_index :phones, [:prefix, :number], unique: true
  end
end
