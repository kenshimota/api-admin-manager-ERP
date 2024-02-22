class CreateUsersCustomers < ActiveRecord::Migration[7.0]
  def change
    create_table :users_customers do |t|
      t.references :user, index: {:unique=>true}, null: false, foreign_key: true
      t.references :customer, index: {:unique=>true}, null: false, foreign_key: true

      t.timestamps
    end
  end
end
