FactoryBot.define do
  factory :currency do
    code { "USD" }
    name { "Dolar de Estados Unidos" }
    symbol { "$" }
    exchange_rate { 38.2 }
  end
end
