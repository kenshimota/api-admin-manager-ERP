ORDER_STATUSES_NAME = {
  pending: "pending-status",
  invoiced: "invoice-status",
  canceled: "canceled-status",
}.freeze

USERS_BASE_TEST = {
  admin: {
    username: "admin",
    first_name: "Administrador",
    last_name: "Apellido",
    identity_document: 17891546,
    password: "managEr1.",
    email: "admin@example.com",
  },
}.freeze

CURRENCIES_BASE = {
  VES: { name: "Bolivar Venezolano", exchange_rate: 1, symbol: "Bss" },
  USD: { name: "Dolar Estado Unidense", exchange_rate: 37.23, symbol: "$" },
}.freeze


USERS_ROLES_CONST = {
  manager: "manager",
  customer: "customer",
  inventory: "inventory-specialist",
  sale: "sale-person",
}.freeze