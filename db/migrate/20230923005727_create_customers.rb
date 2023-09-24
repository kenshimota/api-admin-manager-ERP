class CreateCustomers < ActiveRecord::Migration[7.0]
  def change
    create_table :customers do |t|
      t.string :name
      t.string :last_name
      t.bigint :identity_document
      t.references :state, null: false, foreign_key: true
      t.references :city, null: false, foreign_key: true
      t.string :address

      t.timestamps
    end
    add_index :customers, :identity_document, unique: true
  end
end
