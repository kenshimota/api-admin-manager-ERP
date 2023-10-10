FactoryBot.define do
  factory :product do
    name { "product app - 1" }
    code { "MyString" }
    bar_code { "12345678" }
    tax { Tax.first || FactoryBot.create(:tax_with_percentage) }
  end
end
