class CreateInventoriesHistories < ActiveRecord::Migration[7.0]
  def change
    create_table :inventories_histories do |t|
      t.references :inventory, null: false, foreign_key: true
      t.integer :before_amount, :default => 0
      t.integer :after_amount, :default => 0
      t.references :user, null: false, foreign_key: true
      t.string :observations

      t.timestamps
    end
  end
end
