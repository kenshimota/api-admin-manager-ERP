FactoryBot.define do
  factory :product do
    name { "MyString" }
    code { "MyString" }
    stock { 1 }
    reserved { 1 }
    tax { nil }
  end
end
