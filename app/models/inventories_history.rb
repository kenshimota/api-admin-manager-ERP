class InventoriesHistory < ApplicationRecord
  belongs_to :user
  belongs_to :inventory
  has_one :product, through: :inventory
  has_one :warehouse, through: :inventory

  validates :user_id, presence: true
  validates :inventory_id, presence: true

  validates :after_amount, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :before_amount, presence: true, numericality: { greater_than_or_equal_to: 0 }

  scope :filter_inventory, ->(inventory_id) { inventory_id ? where(inventory_id: inventory_id) : self }
  scope :filter_product, ->(product_id) { product_id ? where(inventory: Inventory.where(product_id: product_id)) : self }
  scope :filter_warehouse, ->(warehouse_id) { warehouse_id ? where(inventory: Inventory.where(warehouse_id: warehouse_id)) : self }
end
