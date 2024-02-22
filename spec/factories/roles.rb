FactoryBot.define do
  factory :role_manager, class: Role do
    name { USERS_ROLES_CONST[:manager] }
  end

  factory :role_inventory, class: Role do
    name { USERS_ROLES_CONST[:inventory] }
  end

  factory :role_customer, class: Role do
    name { USERS_ROLES_CONST[:customer] }
  end

  factory :role_sale, class: Role do
    name { USERS_ROLES_CONST[:sale] }
  end
end