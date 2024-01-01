require "rails_helper"

RSpec.describe "Orders", type: :request do
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

      while n < 35
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

    it "a user can't see the orders only if you've signin" do
      get orders_url
      expect(response).to have_http_status(:unauthorized)
    end

    it "the orders page '1'", authorized: true do
      get orders_url
      body = JSON.parse(response.body)
      expect(response).to have_http_status(:ok)
      expect(body.length).to be(20)
    end

    it "the orders page '2'", authorized: true do
      get orders_url, params: { page: 2 }
      body = JSON.parse(response.body)

      expect(response).to have_http_status(:ok)
      expect(body.length).to be(15)
    end

    it "the orders page '1', orders_status_id ':id'", authorized: true do
      last = Order.joins(:orders_status).includes(:orders_status).last
      status = OrdersStatus.where(name: ORDER_STATUSES_NAME[:invoiced]).first
      last.set_user User.first
      last.update!(orders_status_id: status.id)

      get orders_url, params: { orders_status_id: status.id }
      body = JSON.parse(response.body)

      expect(response).to have_http_status(:ok)
      expect(body.length).to be(1)
    end

    it "the orders page '2', orders_status_id ':id'", authorized: true do
      last = Order.joins(:orders_status).includes(:orders_status).last
      status = OrdersStatus.where(name: ORDER_STATUSES_NAME[:invoiced]).first
      last.set_user User.first
      last.update!(orders_status_id: status.id)

      get orders_url, params: { page: 2, orders_status_id: status.id }
      body = JSON.parse(response.body)

      expect(response).to have_http_status(:ok)
      expect(body.length).to be(0)
    end

    it "the orders  page: '1', customer_id ':id'", authorized: true do
      c = Customer.last
      get orders_url, params: { customer_id: c.id }
      body = JSON.parse(response.body)

      expect(response).to have_http_status(:ok)
      expect(body.length).to be(1)
    end

    it "the orders  page: '1', customer_id ':id'", authorized: true do
      c = Customer.last
      get orders_url, params: { customer_id: c.id, page: 2 }
      body = JSON.parse(response.body)

      expect(response).to have_http_status(:ok)
      expect(body.length).to be(0)
    end

    it "the orders  page: '1', currency_id ':id'", authorized: true do
      current_currency = FactoryBot.create(:currency_bss)
      current_order = Order.new(user: user, currency: current_currency, customer: customer)
      current_order.save!

      get orders_url, params: { currency_id: current_currency.id }
      body = JSON.parse(response.body)

      expect(response).to have_http_status(:ok)
      expect(body.length).to be(1)
    end

    it "the orders  page: '2', currency_id ':id'", authorized: true do
      current_currency = FactoryBot.create(:currency_bss)
      current_order = Order.new(user: user, currency: current_currency, customer: customer)
      current_order.save!

      get orders_url, params: { currency_id: current_currency.id, page: 2 }
      body = JSON.parse(response.body)

      expect(response).to have_http_status(:ok)
      expect(body.length).to be(0)
    end

    it "the orders  page: '1', user_id ':id'", authorized: true do
      current_user = FactoryBot.create(:user_aux)
      current_order = Order.new(user: current_user, currency: currency, customer: customer)
      current_order.save!

      get orders_url, params: { user_id: current_user.id }
      body = JSON.parse(response.body)

      expect(response).to have_http_status(:ok)
      expect(body.length).to be(1)
      expect(body[0]["id"]).to eq(current_order.id)
    end

    it "the orders page: '2', user_id ':id'", authorized: true do
      current_user = FactoryBot.create(:user_aux)
      current_order = Order.new(user: current_user, currency: currency, customer: customer)
      current_order.save!

      get orders_url, params: { user_id: current_user.id, page: 2 }
      body = JSON.parse(response.body)

      expect(response).to have_http_status(:ok)
      expect(body.length).to be(0)
    end

    it "the orders q ':username'", authorized: true do
      current_user = FactoryBot.create(:user_aux)
      current_order = Order.new(user: current_user, currency: currency, customer: customer)
      current_order.save!

      get orders_url, params: { q: current_user.username.upcase }
      body = JSON.parse(response.body)

      expect(response).to have_http_status(:ok)
      expect(body.length).to be(1)
    end

    it "the orders params q ':username' and metadata '1'", authorized: true do
      current_user = FactoryBot.create(:user_aux)
      current_order = Order.new(user: current_user, currency: currency, customer: customer)
      current_order.save!

      get orders_url, params: { q: current_user.username.upcase, metadata: 1 }
      body = JSON.parse(response.body)

      expect(response).to have_http_status(:ok)
      expect(body.length).to be(1)
    end

    it "the orders params query metadata '1'", authorized: true do
      get orders_url, params: { metadata: 1 }
      body = JSON.parse(response.body)
      first = body.first

      expect(response).to have_http_status(:ok)
      expect(body.length).to be(20)

      expect(first["user"].nil?).to be(false)
      expect(first["customer"].nil?).to be(false)
      expect(first["currency"].nil?).to be(false)
      expect(first["orders_status"].nil?).to be(false)
    end
  end

  describe "GET /show" do
    it "you can't  see an order if you didn't signin" do
      get order_url(order), as: :json
      expect(response).to have_http_status(:unauthorized)
    end

    it "show order success", authorized: true do
      get order_url(order), as: :json
      body = JSON.parse(response.body)

      expect(response).to have_http_status(:ok)
      expect(body["id"]).to eq(order.id)
      expect(body["customer"].nil?).to be(false)
      expect(body["currency"].nil?).to be(false)
      expect(body["user"].nil?).to be(false)
      expect(body["orders_status"].nil?).to be(false)
    end
  end

  describe "GET /destroy" do
    before(:each) do
      create_inventory_and_price(10.45, product_without_tax, 10000)
      create_inventory_and_price(23.46, product_with_tax, 20000)
    end

    it "you can't delete an order if you didn't signin" do
      delete order_url(order), as: :json
      expect(response).to have_http_status(:unauthorized)
    end

    it "you can't delete an order if it isn't pending", authorized: true do
      status = OrdersStatus.where(name: ORDER_STATUSES_NAME[:invoiced]).first

      quantity = Faker::Number.rand_in_range(1, 80)
      item = OrdersItem.new(order: order, product: product_without_tax, quantity: quantity)
      item.save!

      quantity = Faker::Number.rand_in_range(1, 80)
      item = OrdersItem.new(order: order, product: product_with_tax, quantity: quantity)
      item.save!

      order.set_user User.first
      order.update!(orders_status_id: status.id)

      expect {
        delete order_url(order), as: :json
      }.to change(Order, :count).by(0)
    end

    it "you can't delete an order if it isn't pending", authorized: true do
      status = OrdersStatus.where(name: ORDER_STATUSES_NAME[:invoiced]).first

      quantity = Faker::Number.rand_in_range(1, 80)
      item = OrdersItem.new(order: order, product: product_without_tax, quantity: quantity)
      item.save!

      quantity = Faker::Number.rand_in_range(1, 80)
      item = OrdersItem.new(order: order, product: product_with_tax, quantity: quantity)
      item.save!

      order.set_user User.first

      order.update!(orders_status_id: status.id)
      delete order_url(order), as: :json
      expect(response).to have_http_status(:unprocessable_entity)
    end

    it "delete an order success", authorized: true do
      quantity = Faker::Number.rand_in_range(1, 80)
      item = OrdersItem.new(order: order, product: product_without_tax, quantity: quantity)
      item.save!

      quantity = Faker::Number.rand_in_range(1, 80)
      item = OrdersItem.new(order: order, product: product_with_tax, quantity: quantity)
      item.save!

      expect {
        delete order_url(order), as: :json
      }.to change(Order, :count).by(-1)
    end

    it "delete an order success http", authorized: true do
      quantity = Faker::Number.rand_in_range(1, 80)
      item = OrdersItem.new(order: order, product: product_without_tax, quantity: quantity)
      item.save!

      quantity = Faker::Number.rand_in_range(1, 80)
      item = OrdersItem.new(order: order, product: product_with_tax, quantity: quantity)
      item.save!

      delete order_url(order), as: :json
      expect(response).to have_http_status(:no_content)
    end
  end
end
