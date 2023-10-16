FactoryBot.define do
  factory :products_prices_history do
    products_price { nil }
    user { nil }
    price_before { "9.99" }
    price_after { "9.99" }
  end
end
