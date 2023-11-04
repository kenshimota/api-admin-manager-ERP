class ProductsPricesHistory < ApplicationRecord
  belongs_to :user
  belongs_to :products_price
  has_one :product, through: :products_price
  has_one :currency, through: :products_price
  has_one :tax, through: :product

  scope :search, ->(q) { where(products_price: ProductsPrice.search(q)).or(where(user: User.search(q))) if q and !q.empty? }
  scope :currency_id, lambda { |currency_id| !currency_id ? self : where(products_price: ProductsPrice.where(currency_id: currency_id)) }
  scope :product_id, lambda { |product_id| !product_id ? self : where(products_price: ProductsPrice.where(product_id: product_id)) }
end
