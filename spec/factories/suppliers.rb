FactoryBot.define do
  factory :supplier do
    name { "MyString" }
    email { "MyString" }
    code_postal { 1 }
    identity_document { "" }
    city { nil }
    state { nil }
    address { "MyString" }
  end
end
