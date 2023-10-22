class ProductsPricesHistory < ApplicationRecord
  belongs_to :products_price
  belongs_to :user

  scope :currency_id, lambda { |currency_id| !currency_id ? self : where(products_price: ProductsPrice.where(currency_id: currency_id)) }
  scope :product_id, lambda { |product_id| !product_id ? self : where(products_price: ProductsPrice.where(product_id: product_id)) }
end
