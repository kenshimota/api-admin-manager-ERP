class CreateSuppliers < ActiveRecord::Migration[7.0]
  def change
    create_table :suppliers do |t|
      t.string :name
      t.string :email
      t.integer :code_postal
      t.bigint :identity_document
      t.references :city, null: false, foreign_key: true
      t.references :state, null: false, foreign_key: true
      t.string :address

      t.timestamps
    end
    add_index :suppliers, :identity_document, unique: true
  end
end
