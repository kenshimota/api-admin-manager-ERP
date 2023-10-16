class ProductsPrice < ApplicationRecord
  belongs_to :product
  belongs_to :currency
  has_many :products_prices

  validates :price, presence: true, numericality: { greater_than: 0 }
end
