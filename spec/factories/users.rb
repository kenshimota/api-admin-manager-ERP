FactoryBot.define do
  factory :user do
    username { "gonzalezp" }
    first_name { "Pepito" }
    last_name { "Gonzalez" }
    identity_document { 17891546 }
    password { "managEr1." }
    email { Faker::Internet.email }
  end

  factory :user_aux, class: User do
    username { "auxiliar" }
    first_name { "Pepito" }
    last_name { "Gonzalez" }
    identity_document { 12891546 }
    password { "managEr1." }
    email { "admin-aux@example.com" }
  end
end
