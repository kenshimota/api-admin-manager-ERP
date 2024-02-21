# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.0].define(version: 2024_02_21_031849) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "cities", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_cities_on_name", unique: true
  end

  create_table "currencies", force: :cascade do |t|
    t.string "name", null: false
    t.string "code", null: false
    t.string "symbol"
    t.decimal "exchange_rate", precision: 22, scale: 3, default: "1.0", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["code"], name: "index_currencies_on_code", unique: true
  end

  create_table "customers", force: :cascade do |t|
    t.string "name"
    t.string "last_name"
    t.bigint "identity_document"
    t.bigint "state_id", null: false
    t.bigint "city_id", null: false
    t.string "address"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["city_id"], name: "index_customers_on_city_id"
    t.index ["identity_document"], name: "index_customers_on_identity_document", unique: true
    t.index ["state_id"], name: "index_customers_on_state_id"
  end

  create_table "customers_phones", force: :cascade do |t|
    t.bigint "customer_id", null: false
    t.bigint "phone_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["customer_id", "phone_id"], name: "index_customers_phones_on_customer_id_and_phone_id", unique: true
    t.index ["customer_id"], name: "index_customers_phones_on_customer_id"
    t.index ["phone_id"], name: "index_customers_phones_on_phone_id"
  end

  create_table "inventories", force: :cascade do |t|
    t.bigint "product_id", null: false
    t.integer "stock", default: 0, null: false
    t.integer "reserved", default: 0, null: false
    t.bigint "warehouse_id", null: false
    t.string "observations"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["product_id", "warehouse_id"], name: "index_inventories_on_product_id_and_warehouse_id", unique: true
    t.index ["product_id"], name: "index_inventories_on_product_id"
    t.index ["warehouse_id"], name: "index_inventories_on_warehouse_id"
  end

  create_table "inventories_histories", force: :cascade do |t|
    t.bigint "inventory_id", null: false
    t.integer "before_amount", default: 0
    t.integer "after_amount", default: 0
    t.bigint "user_id", null: false
    t.string "observations"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["inventory_id"], name: "index_inventories_histories_on_inventory_id"
    t.index ["user_id"], name: "index_inventories_histories_on_user_id"
  end

  create_table "items_inventories", force: :cascade do |t|
    t.bigint "orders_item_id", null: false
    t.bigint "inventory_id", null: false
    t.integer "quantity", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["inventory_id"], name: "index_items_inventories_on_inventory_id"
    t.index ["orders_item_id", "inventory_id"], name: "index_items_inventories_on_orders_item_id_and_inventory_id", unique: true
    t.index ["orders_item_id"], name: "index_items_inventories_on_orders_item_id"
  end

  create_table "orders", force: :cascade do |t|
    t.integer "number"
    t.bigint "user_id", null: false
    t.bigint "customer_id", null: false
    t.bigint "orders_status_id", null: false
    t.bigint "currency_id", null: false
    t.decimal "subtotal", precision: 24, scale: 3, default: "0.0", null: false
    t.decimal "tax_amount", precision: 24, scale: 3, default: "0.0", null: false
    t.decimal "total", precision: 24, scale: 3, default: "0.0", null: false
    t.integer "products_count", default: 0
    t.integer "quantity_total", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["currency_id"], name: "index_orders_on_currency_id"
    t.index ["customer_id"], name: "index_orders_on_customer_id"
    t.index ["number"], name: "index_orders_on_number", unique: true
    t.index ["orders_status_id"], name: "index_orders_on_orders_status_id"
    t.index ["user_id"], name: "index_orders_on_user_id"
  end

  create_table "orders_items", force: :cascade do |t|
    t.bigint "product_id", null: false
    t.bigint "order_id", null: false
    t.bigint "currency_id", null: false
    t.decimal "price_without_tax", precision: 24, scale: 3, null: false
    t.decimal "price", precision: 24, scale: 3, null: false
    t.integer "quantity", null: false
    t.decimal "subtotal", precision: 24, scale: 3, null: false
    t.decimal "tax_amount", precision: 24, scale: 3, null: false
    t.decimal "total", precision: 24, scale: 3, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["currency_id"], name: "index_orders_items_on_currency_id"
    t.index ["order_id", "product_id"], name: "index_orders_items_on_order_id_and_product_id", unique: true
    t.index ["order_id"], name: "index_orders_items_on_order_id"
    t.index ["product_id"], name: "index_orders_items_on_product_id"
  end

  create_table "orders_statuses", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_orders_statuses_on_name", unique: true
  end

  create_table "phones", force: :cascade do |t|
    t.integer "prefix", null: false
    t.bigint "number", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["prefix", "number"], name: "index_phones_on_prefix_and_number", unique: true
  end

  create_table "products", force: :cascade do |t|
    t.string "name", null: false
    t.string "code"
    t.string "bar_code"
    t.integer "stock", default: 0, null: false
    t.integer "reserved", default: 0, null: false
    t.bigint "tax_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["code"], name: "index_products_on_code", unique: true
    t.index ["tax_id"], name: "index_products_on_tax_id"
  end

  create_table "products_prices", force: :cascade do |t|
    t.decimal "price", precision: 24, scale: 3, default: "1.0", null: false
    t.bigint "product_id", null: false
    t.bigint "currency_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["currency_id"], name: "index_products_prices_on_currency_id"
    t.index ["product_id", "currency_id"], name: "index_products_prices_on_product_id_and_currency_id", unique: true
    t.index ["product_id"], name: "index_products_prices_on_product_id"
  end

  create_table "products_prices_histories", force: :cascade do |t|
    t.bigint "products_price_id", null: false
    t.bigint "user_id", null: false
    t.decimal "price_before", precision: 24, scale: 3, default: "1.0", null: false
    t.decimal "price_after", precision: 24, scale: 3, default: "1.0", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["products_price_id"], name: "index_products_prices_histories_on_products_price_id"
    t.index ["user_id"], name: "index_products_prices_histories_on_user_id"
  end

  create_table "roles", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_roles_on_name", unique: true
  end

  create_table "states", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_states_on_name", unique: true
  end

  create_table "taxes", force: :cascade do |t|
    t.string "name", null: false
    t.decimal "percentage", precision: 5, scale: 4, default: "0.0", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_taxes_on_name", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.string "username", null: false
    t.string "first_name", null: false
    t.string "last_name", null: false
    t.bigint "identity_document", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "jti", null: false
    t.string "reset_code", limit: 6
    t.datetime "reset_code_sent_at"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["identity_document"], name: "index_users_on_identity_document", unique: true
    t.index ["jti"], name: "index_users_on_jti", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["username"], name: "index_users_on_username", unique: true
  end

  create_table "users_customers", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "customer_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["customer_id"], name: "index_users_customers_on_customer_id", unique: true
    t.index ["user_id"], name: "index_users_customers_on_user_id", unique: true
  end

  create_table "users_roles", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "role_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["role_id"], name: "index_users_roles_on_role_id"
    t.index ["user_id"], name: "index_users_roles_on_user_id", unique: true
  end

  create_table "warehouses", force: :cascade do |t|
    t.string "name", null: false
    t.string "address"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_warehouses_on_name", unique: true
  end

  add_foreign_key "customers", "cities"
  add_foreign_key "customers", "states"
  add_foreign_key "customers_phones", "customers"
  add_foreign_key "customers_phones", "phones"
  add_foreign_key "inventories", "products"
  add_foreign_key "inventories", "warehouses"
  add_foreign_key "inventories_histories", "inventories"
  add_foreign_key "inventories_histories", "users"
  add_foreign_key "items_inventories", "inventories"
  add_foreign_key "items_inventories", "orders_items"
  add_foreign_key "orders", "currencies"
  add_foreign_key "orders", "customers"
  add_foreign_key "orders", "orders_statuses"
  add_foreign_key "orders", "users"
  add_foreign_key "orders_items", "currencies"
  add_foreign_key "orders_items", "orders"
  add_foreign_key "orders_items", "products"
  add_foreign_key "products", "taxes"
  add_foreign_key "products_prices", "currencies"
  add_foreign_key "products_prices", "products"
  add_foreign_key "products_prices_histories", "products_prices"
  add_foreign_key "products_prices_histories", "users"
  add_foreign_key "users_customers", "customers"
  add_foreign_key "users_customers", "users"
  add_foreign_key "users_roles", "roles"
  add_foreign_key "users_roles", "users"
end
