FactoryBot.define do
  factory :product do
    name { "product app - 1" }
    code { "MyString" }
    bar_code { "12345678" }
    tax { Tax.first || FactoryBot.create(:tax_with_percentage) }
  end

  factory :product_without_tax, class: Product do
    name { "Product without tax" }
    code { "product-tax-1" }
    bar_code { "123456789" }
    tax { Tax.where(percentage: 0).first || FactoryBot.create(:tax_without_percentage) }
  end

  factory :product_with_tax, class: Product do
    name { "Product with tax " }
    code { "product-tax-2" }
    bar_code { "12345678911" }
    tax { Tax.where("percentage  > 0").first || FactoryBot.create(:tax_with_percentage) }
  end
end
