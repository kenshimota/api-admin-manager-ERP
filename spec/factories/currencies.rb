FactoryBot.define do
  factory :currency do
    code { "USD" }
    name { "Dolar de Estados Unidos" }
    symbol { "$" }
    exchange_rate { 38.2 }
  end

  factory :currency_bss, class: Currency do
    code { "VES" }
    name { "Bolivar Venezolano" }
    symbol { "Bss" }
    exchange_rate { 1 }
  end
end
