class ItemsInventory < ApplicationRecord
  belongs_to :orders_item
  belongs_to :inventory

  validates :quantity, presence: true, numericality: { greater_than: 0 }
end
