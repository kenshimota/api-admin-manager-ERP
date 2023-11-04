FactoryBot.define do
  factory :order do
    number { 1 }
    user { nil }
    customer { nil }
    orders_status { nil }
    currency { nil }
    subtotal { "9.99" }
    tax_amount { "9.99" }
    total { "9.99" }
    products_count { 1 }
    quantity_total { 1 }
  end
end
