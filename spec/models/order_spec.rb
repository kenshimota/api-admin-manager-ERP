require "rails_helper"

RSpec.describe Order, type: :model do
  let(:user) { User.first || FactoryBot.create(:user) }
  let(:currency) { Currency.first || FactoryBot.create(:currency) }
  let(:customer) { Customer.first || FactoryBot.create(:customer) }
  let(:valid_params) { { user_id: user.id, customer_id: customer.id, currency_id: currency.id } }

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

  context "create order" do
    it "an order doesn't be void" do
      expect(Order.new).to_not be_valid
    end

    it "an order doesn't be currency_id void" do
      data = valid_params.clone

      data[:currency_id] = nil
      expect(Order.create(data)).to_not be_valid

      data[:currency_id] = ""
      expect(Order.create(data)).to_not be_valid
    end

    it "an order doesn't be customer_id void" do
      data = valid_params.clone

      data[:customer_id] = nil
      expect(Order.create(data)).to_not be_valid

      data[:customer_id] = ""
      expect(Order.create(data)).to_not be_valid
    end

    it "an order doesn't be user_id void" do
      data = valid_params.clone

      data[:user_id] = nil
      expect(Order.create(data)).to_not be_valid

      data[:user_id] = ""
      expect(Order.create(data)).to_not be_valid
    end

    it "an order create a number secuencial and an order number can't repeat it" do
      order_1 = Order.create(valid_params)
      expect(order_1).to be_valid
      expect(order_1.number).to be(1)

      order_2 = Order.create(valid_params)
      expect(order_2).to be_valid
      expect(order_2.number).to be(2)

      order_2.destroy

      order_3 = Order.create(valid_params)
      expect(order_3).to be_valid
      expect(order_3.number).to be(2)
      expect(order_3.update(number: 1)).to be(false)
    end
  end

  context "update an order" do
    let(:order) { Order.create(valid_params) }

    it "tax_amount can't be fewer than zero" do
      expect(order.update(tax_amount: -1)).to be(false)
      expect(order.update(tax_amount: 1)).to be(true)
      expect(order.update(tax_amount: 0)).to be(true)
    end

    it "subtotal can't be fewer than zero" do
      expect(order.update(subtotal: -1)).to be(false)
      expect(order.update(subtotal: 1)).to be(true)
      expect(order.update(subtotal: 0)).to be(true)
    end

    it "total can't be fewer than zero" do
      expect(order.update(total: -1)).to be(false)
      expect(order.update(total: 1)).to be(true)
      expect(order.update(total: 0)).to be(true)
    end

    it "products_quantity can't be fewer than zero" do
      expect(order.update(products_count: -1)).to be(false)
      expect(order.update(products_count: 1)).to be(true)
      expect(order.update(products_count: 0)).to be(true)
    end

    it "quantity_total can't be fewer than zero" do
      expect(order.update(quantity_total: -1)).to be(false)
      expect(order.update(quantity_total: 1)).to be(true)
      expect(order.update(quantity_total: 0)).to be(true)
    end

    it "you only edit an order pending" do
      status = OrdersStatus.where(name: ORDER_STATUSES_NAME[:invoiced]).first
      order.update(orders_status_id: status.id)
      expect(order.update(quantity_total: 1)).to be(false)

      status = OrdersStatus.where(name: ORDER_STATUSES_NAME[:canceled]).first
      order.update(orders_status_id: status.id)
      expect(order.update(quantity_total: 2)).to be(false)
    end
  end

  context "destroy an order" do
    it "you only delete an order pending" do
      order1 = Order.create(valid_params)
      status = OrdersStatus.where(name: ORDER_STATUSES_NAME[:invoiced]).first
      order1.update!(orders_status_id: status.id)
      expect { order1.destroy }.to change(Order, :count).by(0)

      order2 = Order.create(valid_params)
      status = OrdersStatus.where(name: ORDER_STATUSES_NAME[:canceled]).first
      order2.update!(orders_status_id: status.id)
      expect { order2.destroy }.to change(Order, :count).by(0)

      order3 = Order.create(valid_params)
      status = OrdersStatus.where(name: ORDER_STATUSES_NAME[:pending]).first
      order3.update!(orders_status_id: status.id)
      expect { order3.destroy }.to change(Order, :count).by(-1)
    end
  end
end
