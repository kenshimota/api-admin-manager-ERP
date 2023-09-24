FactoryBot.define do
  factory :customers_phone do
    customer { FactoryBot.create(:customer) }
    phone { FactoryBot.create(:phone) }
  end
end
