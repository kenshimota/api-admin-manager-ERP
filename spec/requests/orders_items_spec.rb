require "rails_helper"

RSpec.describe "OrdersItems", type: :request do
  let(:user) { User.first || FactoryBot.create(:user) }
  let(:currency) { Currency.first || FactoryBot.create(:currency) }
  let(:customer) { Customer.first || FactoryBot.create(:customer) }
  let(:warehouse1) { FactoryBot.create(:warehouse) }
  let(:warehouse2) { FactoryBot.create(:warehouse_aux) }
  let(:order) { Order.find_or_create_by(user_id: user.id, customer_id: customer.id, currency_id: currency.id) }
  let(:product_without_tax) { Product.first || FactoryBot.create(:product_without_tax) }
  let(:product_with_tax) { Product.where(tax: Tax.where("percentage > 0")).first || FactoryBot.create(:product_with_tax) }

  let(:name) do
    str = ""
    while str.length < 3
      str = Faker::Name.first_name
    end
    str
  end

  let(:last_name) do
    str = ""
    while str.length < 3
      str = Faker::Name.last_name
    end
    str
  end

  def create_inventory_and_price(price_base, product, instock)
    price = ProductsPrice.new(product_id: product.id, currency_id: currency.id, price: price_base)
    price.set_user user
    price.save!

    stock1 = (instock / 2).to_i
    stock2 = instock - stock1

    inventory1 = Inventory.new(stock: stock1, product_id: product.id, warehouse_id: warehouse1.id)
    inventory1.set_user user
    inventory1.save!

    inventory2 = Inventory.new(stock: stock2, product_id: product.id, warehouse_id: warehouse2.id)
    inventory2.set_user user
    inventory2.save!
  end

  before(:all) do
    ORDER_STATUSES_NAME.each do |key, value|
      OrdersStatus.find_or_create_by(name: value)
    end
  end

  after(:all) do
    ORDER_STATUSES_NAME.each do |key, value|
      OrdersStatus.limit(1).destroy_by(name: value)
    end
  end

  describe "GET /index" do
    before(:each) do
      n = 0

      create_inventory_and_price(10.45, product_without_tax, 10000)
      create_inventory_and_price(23.46, product_with_tax, 20000)

      while n < 20
        data = {
          name: name,
          last_name: last_name,
          identity_document: Faker::Number.number(digits: 8),
          address: Faker::Address.street_address,
          state: State.find_or_create_by(name: Faker::Address.state),
          city: City.find_or_create_by(name: Faker::Address.city),
        }

        custom = Customer.create!(data)
        sale = Order.create!(user_id: user.id, customer_id: custom.id, currency_id: currency.id)

        quantity = Faker::Number.rand_in_range(1, 80)
        item = OrdersItem.new(order: sale, product: product_without_tax, quantity: quantity)
        item.save!

        quantity = Faker::Number.rand_in_range(1, 80)
        item = OrdersItem.new(order: sale, product: product_with_tax, quantity: quantity)
        item.save!

        n += 1
      end
    end

    it "returns http success" do
      get "/orders_items/index"
      expect(response).to have_http_status(:success)
    end
  end

=begin

  describe "GET /show" do
    it "returns http success" do
      get "/orders_items/show"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /create" do
    it "returns http success" do
      get "/orders_items/create"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /destroy" do
    it "returns http success" do
      get "/orders_items/destroy"
      expect(response).to have_http_status(:success)
    end
  end

=end
end
