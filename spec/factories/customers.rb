FactoryBot.define do
  factory :customer do
    name { "Pepito" }
    last_name { "Apellido" }
    identity_document { "19785426" }
    state { State.create(name: "MyUniqueState") }
    city { City.create(name: "MyUniqueCity") }
    address { "address example" }
  end
end
