# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: "Star Wars" }, { name: "Lord of the Rings" }])
#   Character.create(name: "Luke", movie: movies.first)

states = ["Amazonas", "Anzoátegui", "Apure", "Aragua", "Barinas", "Bolívar",
          "Carabobo", "Cojedes", "Delta Amacuro", "Dependencias Federales",
          "Distrito Federal", "Falcón", "Guárico", "Lara", "Mérida", "Miranda",
          "Monagas", "Nueva Esparta", "Portuguesa", "Sucre", "Táchira",
          "Trujillo", "Vargas", "Yaracuy", "Zulia"]

cities = [
  "Caracas", "Maracaibo", "Valencia", "Barquisimeto", "Maracay",
  "Ciudad Guayana", "Maturín", "Barinas", "San Cristóbal", "Ciudad Bolívar",
  "Barcelona", "Cumaná", "Cabimas", "Mérida", "Puerto La Cruz", "Guatire", "Ciudad Ojeda",
  "Punto Fijo", "Coro", "Turmero", "Los Teques", "Guanare", "Tocuyito", "San Felipe", "Acarigua",
  "Carora", "El Tigre", "Guarenas", "Cabudare", "Carúpano", "San Fernando de Apure", "Guacara", "Puerto Cabello",
  "Valera", "La Victoria", "Los Guayos", "Santa Rita", "Güigüe", "Anaco", "San Juan de los Morros",
  "El Vigía", "Palo Negro", "San Carlos", "Mariara", "Villa de Cura", "Ocumare del Tuy", "Yaritagua",
  "Cúa", "Araure", "Calabozo", "Táriba", "Guasdualito", "Puerto Ayacucho", "Machiques", "Cagua", "Porlamar",
  "Charallave", "La Asunción", "Valle de la Pascua", "Santa Lucía", "Trujillo", "Quíbor", "Tinaquillo",
  "Puerto Píritu", "El Limón", "Socopó", "Boconó", "Punta de Mata", "Ejido", "Upata", "Rubio", "Caja Seca",
  "Catia La Mar", "Tumeremo", "Caripito", "La Grita", "Santa Bárbara del Zulia", "Tucupita",
  "San José de Guanipa", "Chivacoa", "Lechería", "Zaraza", "Nirgua", "", "Santa Rita", "Guanta",
  "Morón", "Pariaguán", "San Juan de Colón", "San Joaquín", "San Antonio de los Altos", "Caicara del Orinoco",
  "Achaguas", "Biruaca", "Santa Bárbara (Barinas)", "La Guaira", "Bachaquero",
]

taxes = [
  { name: "Sin IVA", percentage: 0.00 },
  { name: "IVA", percentage: 0.16 },
]

states.each do |state_name|
  State.find_or_create_by(name: state_name)
end

cities.each do |city_name|
  City.find_or_create_by(name: city_name)
end

taxes.each do |tax_data|
  Tax.find_or_create_by(tax_data)
end

ORDER_STATUSES_NAME.each do |key, value|
  OrdersStatus.find_or_create_by(name: value)
end

# TEST SEED
CURRENCIES_BASE.each do |key, data|
  attributes = data.clone
  attributes[:code] = key
  Currency.find_or_create_by(attributes)
end

USERS_BASE_TEST.each do |key, data|
  u = User.where(email: data[:email]).first
  if u
    next
  end

  User.create!(data)
end

user = User.first
tax = Tax.first
currency = Currency.where(code: "USD").first

customer = Customer.find_or_create_by!(
  name: "Pepito",
  last_name: "Generico",
  identity_document: "19785426",
  state_id: State.first.id,
  city_id: City.first.id,
  address: "address example",
)

warehouse = Warehouse.find_or_create_by!(name: "warehouse 1", address: "address 1")
product = Product.find_or_create_by!(name: "Cauchos 1", code: "CAU001", tax_id: tax.id)

if ProductsPrice.first.nil?
  product_price = ProductsPrice.new(price: 10, currency_id: currency.id, product_id: product.id)
  product_price.set_user user
  product_price.save!
end

if Inventory.where(product_id: product.id, warehouse_id: warehouse.id).first.nil?
  i = Inventory.new(product_id: product.id, stock: 1000, warehouse_id: warehouse.id, observations: "test")
  i.set_user user
  i.save!
end

order = Order.find_or_create_by(customer_id: customer.id, user_id: user.id, currency_id: currency.id)
