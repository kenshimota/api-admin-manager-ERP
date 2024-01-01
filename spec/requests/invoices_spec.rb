require "rails_helper"

RSpec.describe "Invoices", type: :request do
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

  describe "POST /create" do
    let(:valid_attributes) { { order_id: order.id } }
    let(:item_without_tax) { OrdersItem.find!(order_id: order.id, product_id: product_without_tax.id) }
    let(:item_with_tax) { OrdersItem.find!(order_id: order.id, product_id: product_with_tax.id) }

    before(:each) do
      create_inventory_and_price(10.45, product_without_tax, 10000)
      create_inventory_and_price(23.46, product_with_tax, 20000)

      item = OrdersItem.new(order: order, product: product_without_tax, quantity: 10)
      item.save!

      item = OrdersItem.new(order: order, product: product_with_tax, quantity: 5)
      item.save!
    end

    context "without signin" do
      it "creates a new invoice" do
        post invoices_url, params: { inventory: valid_attributes }, as: :json
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context "with valid parameters" do
      it "renders a JSON response with the new invoice", authorized: true do
        post invoices_url,
             params: { invoice: valid_attributes }, as: :json
        expect(response).to have_http_status(:created)
        expect(response.content_type).to match(a_string_including("application/json"))
      end

      it "check change on database with the new invoice", authorized: true do
        items = ItemsInventory.where(orders_item: OrdersItem.where(order_id: order.id))
        inventories = items.map { |item| item.inventory }
        expect_stock = items.map { |item| item.inventory.stock - item.quantity }

        post invoices_url, params: { invoice: valid_attributes }, as: :json

        response_stock = inventories.map do |inventory|
          inventory.reload
          inventory.stock
        end

        expect(inventories.map { |inventory| inventory.reserved }).to eq(inventories.map { |inventory| 0 })
        expect(response_stock).to eq(expect_stock)
      end
    end

    context "with invalid parameters" do
      it "renders a JSON response with errors for the new invoice", authorized: true do
        invalid_attributes = valid_attributes.clone
        invalid_attributes[:order_id] = nil

        post invoices_url,
             params: { invoice: invalid_attributes }, as: :json
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.content_type).to match(a_string_including("application/json"))
      end
    end

    context "with valid parameters but the order doesn't pending" do
      it "renders a JSON response with errors for the new invoice", authorized: true do
        invalid_attributes = valid_attributes.clone
        invalid_attributes[:order_id] = nil

        status = OrdersStatus.where(name: ORDER_STATUSES_NAME[:invoiced]).first
        order.set_user User.first
        order.update!(orders_status_id: status.id)

        post invoices_url,
             params: { invoice: invalid_attributes }, as: :json
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.content_type).to match(a_string_including("application/json"))
      end

      it "renders a JSON response with errors for the new invoice", authorized: true do
        invalid_attributes = valid_attributes.clone
        invalid_attributes[:order_id] = nil

        status = OrdersStatus.where(name: ORDER_STATUSES_NAME[:canceled]).first
        order.update!(orders_status_id: status.id)

        post invoices_url,
             params: { invoice: invalid_attributes }, as: :json
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.content_type).to match(a_string_including("application/json"))
      end
    end
  end
end
