class ProductsPricesHistory < ApplicationRecord
  belongs_to :products_price
  belongs_to :user
end
