require "rails_helper"

RSpec.describe "OrdersItems", type: :request do
  let(:warehouse1) { FactoryBot.create(:warehouse) }
  let(:warehouse2) { FactoryBot.create(:warehouse_aux) }
  let(:user) { User.first || FactoryBot.create(:user) }
  let(:currency) { Currency.first || FactoryBot.create(:currency) }
  let(:customer) { Customer.first || FactoryBot.create(:customer) }
  let(:product_without_tax) { Product.first || FactoryBot.create(:product_without_tax) }
  let(:order) { Order.find_or_create_by(user_id: user.id, customer_id: customer.id, currency_id: currency.id) }
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

  def create_orders_seed(count)
    n = 0

    while n < count
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
      create_inventory_and_price(10.45, product_without_tax, 10000)
      create_inventory_and_price(23.46, product_with_tax, 20000)
      create_orders_seed 22
    end

    it "a user can't see the orders only if you've signin" do
      get orders_items_url
      expect(response).to have_http_status(:unauthorized)
    end

    it "the orders page '1'", authorized: true do
      get orders_items_url
      body = JSON.parse(response.body)
      expect(response).to have_http_status(:ok)
      expect(body.length).to be(20)
    end

    it "the orders page '3'", authorized: true do
      get orders_items_url, params: { page: 3 }
      body = JSON.parse(response.body)

      expect(response).to have_http_status(:ok)
      expect(body.length).to be(4)
    end

    it "the orders order_id ':id'", authorized: true do
      order = Order.last

      get orders_items_url, params: { order_id: order.id }
      body = JSON.parse(response.body)

      expect(response).to have_http_status(:ok)
      expect(body.length).to be(2)
    end

    it "the orders customer_id ':id'", authorized: true do
      customer = Customer.last

      get orders_items_url, params: { customer_id: customer.id }
      body = JSON.parse(response.body)

      expect(response).to have_http_status(:ok)
      expect(body.length).to be(2)
    end

    it "the orders product_id ':id', page '1' ", authorized: true do
      product = Product.last

      get orders_items_url, params: { product_id: product.id }
      body = JSON.parse(response.body)

      expect(response).to have_http_status(:ok)
      expect(body.length).to be(20)
    end

    it "the orders product_id ':id', page '2' ", authorized: true do
      product = Product.last

      get orders_items_url, params: { product_id: product.id, page: 2 }
      body = JSON.parse(response.body)

      expect(response).to have_http_status(:ok)
      expect(body.length).to be(2)
    end

    it "the orders product_id ':id', page '2' ", authorized: true do
      product = Product.last

      get orders_items_url, params: { product_id: product.id, page: 2 }
      body = JSON.parse(response.body)

      expect(response).to have_http_status(:ok)
      expect(body.length).to be(2)
    end

    it "the orders currency_id ':id' that it doesn't have records", authorized: true do
      currency = FactoryBot.create(:currency_bss)
      get orders_items_url, params: { currency_id: currency.id }
      body = JSON.parse(response.body)

      expect(response).to have_http_status(:ok)
      expect(body.length).to be(0)
    end

    it "the orders currency_id ':id' that it have all records", authorized: true do
      get orders_items_url, params: { currency_id: currency.id }
      body = JSON.parse(response.body)

      expect(response).to have_http_status(:ok)
      expect(body.length).to be(20)
    end
  end

  describe "GET /show" do
    let(:item) { OrdersItem.last }

    before(:each) do
      create_inventory_and_price(20.78, product_without_tax, 10000)
      create_inventory_and_price(23.46, product_with_tax, 20000)
      create_orders_seed 1
    end

    it "a user can't see an item only if you've signin" do
      get orders_item_path(item)
      expect(response).to have_http_status(:unauthorized)
    end

    it "returns http success", authorized: true do
      get orders_item_path(item)
      body = JSON.parse(response.body)
      expect(response).to have_http_status(:success)
      expect(body["id"]).to eq(item.id)
    end
  end

  describe "GET /create" do
    let(:valid_attributes) { { product_id: product_with_tax.id, order_id: order.id, quantity: 2 } }
    let(:invalid_attributes) { { product_id: product_with_tax.id, order_id: order.id, quantity: 0 } }

    before(:each) do
      create_inventory_and_price(20.78, product_without_tax, 10000)
      create_inventory_and_price(23.46, product_with_tax, 20000)
    end

    it "an user can't create an item only if you've signin" do
      post orders_items_url, params: { item: valid_attributes }
      expect(response).to have_http_status(:unauthorized)
    end

    it "return http failed check change model", authorized: true do
      expect {
        post orders_items_url, params: { item: invalid_attributes }
      }.to change(OrdersItem, :count).by(0)
    end

    it "return http failed check response", authorized: true do
      post orders_items_url, params: { item: invalid_attributes }
      body = JSON.parse(response.body)

      expect(response).to have_http_status(:unprocessable_entity)
      expect(body["errors"].nil?).to eq(false)
    end

    it "return http success check change model", authorized: true do
      expect {
        post orders_items_url, params: { item: valid_attributes }
      }.to change(OrdersItem, :count).by(1)
    end

    it "return http success check response", authorized: true do
      post orders_items_url, params: { item: valid_attributes }
      body = JSON.parse(response.body)
      item = OrdersItem.last

      expect(response).to have_http_status(:created)
      expect(body["id"]).to eq(item.id)
    end
  end

  describe "GET /destroy" do
    let(:item) { OrdersItem.last }
    let(:valid_attributes) { { product_id: product_with_tax.id, order_id: order.id, quantity: 2 } }

    before(:each) do
      create_inventory_and_price(20.78, product_without_tax, 10000)
      create_inventory_and_price(23.46, product_with_tax, 20000)
      OrdersItem.create!(valid_attributes)
    end

    it "an user can't delete an item only if you've signin" do
      delete orders_item_path(item)
      expect(response).to have_http_status(:unauthorized)
    end

    context "when order is invoiced" do
      let(:invoice_status) { OrdersStatus.find_by(name: ORDER_STATUSES_NAME[:invoiced]) }

      before(:each) do
        order.update!(orders_status_id: invoice_status.id)
      end

      it "return http failed because order isn't pending check model", authorized: true do
        expect {
          delete orders_item_path(item)
        }.to change(OrdersItem, :count).by(0)
      end

      it "return http failed because order isn't pending  response", authorized: true do
        delete orders_item_path(item)
        body = JSON.parse(response.body)

        expect(response).to have_http_status(:unprocessable_entity)
        expect(body["errors"].nil?).to be(false)
      end
    end

    context "destroyed item success" do
      let(:pending_status) { OrdersStatus.find_by(name: ORDER_STATUSES_NAME[:pending]) }

      before(:each) do
        order.update!(orders_status_id: pending_status.id)
      end

      it "return http success check model", authorized: true do
        expect {
          delete orders_item_path(item)
        }.to change(OrdersItem, :count).by(-1)
      end

      it "return http success check response", authorized: true do
        delete orders_item_path(item)
        expect(response).to have_http_status(:no_content)
      end
    end
  end
end
