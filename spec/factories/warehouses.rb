FactoryBot.define do
  factory :warehouse do
    name { "warehouse first" }
    address { "address first" }
  end

  factory :warehouse_aux, class: Warehouse do
    name { "warehouse second" }
    address { "address second" }
  end
end
