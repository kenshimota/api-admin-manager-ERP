class CreateOrdersStatuses < ActiveRecord::Migration[7.0]
  def change
    create_table :orders_statuses do |t|
      t.string :name

      t.timestamps
    end
    add_index :orders_statuses, :name, unique: true
  end
end
