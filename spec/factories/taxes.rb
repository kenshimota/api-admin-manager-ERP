FactoryBot.define do
  factory :tax_without_percentage, class: Tax do
    name { "Tax 0%" }
    percentage { 0.16 }
  end

  factory :tax_with_percentega, class: Tax do
    name { "Tax 16.00%" }
    percentage { 0.16 }
  end
end
