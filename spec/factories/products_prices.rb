FactoryBot.define do
  factory :products_price do
    price { Faker::Commerce.price }
    product { Product.first || FactoryBot.create(:product) }
    currency { Currency.first || FactoryBot.create(:currency) }
  end
end
