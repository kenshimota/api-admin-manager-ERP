FactoryBot.define do
  factory :user do
    username { "gonzalezp" }
    first_name { "Pepito" }
    last_name { "Gonzalez" }
    identity_document { 17891546 }
    password { "managEr1." }
    email { Faker::Internet.email }
  end
end
