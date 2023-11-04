require "rails_helper"

RSpec.describe OrdersItem, type: :model do
  let(:user) { User.first || FactoryBot.create(:user) }
  let(:currency) { Currency.first || FactoryBot.create(:currency) }
  let(:customer) { Customer.first || FactoryBot.create(:customer) }
  let(:warehouse1) { FactoryBot.create(:warehouse) }
  let(:warehouse2) { FactoryBot.create(:warehouse_aux) }
  let(:order) { Order.find_or_create_by(user_id: user.id, customer_id: customer.id, currency_id: currency.id) }

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

  describe "add item to an order" do
    context "void params" do
      it "an item doesn't be void" do
        expect(OrdersItem.new).to_not be_valid
      end
    end

    context "with product without tax" do
      let(:price_base) { 23.45 }
      let(:quantity_inventory) { 140 }
      let(:product) { Product.first || FactoryBot.create(:product_without_tax) }

      before(:each) do
        create_inventory_and_price(price_base, product, quantity_inventory)
      end

      it "an item can't have quantity zero" do
        item = OrdersItem.new(order: order, product: product, quantity: 0)
        expect(item).to_not be_valid
      end

      it "create item inside order" do
        quantity = 10
        inventory1 = Inventory.first
        stock = inventory1.stock

        item = OrdersItem.new(order: order, product: product, quantity: quantity)
        item.save!

        inventory1.reload
        product.reload

        expect(item).to be_valid
        expect(item.quantity).to be(quantity)
        expect(item.price_without_tax).to eq(price_base)
        expect(item.price).to eq(price_base)
        expect(item.tax_amount).to eq(0)
        expect(item.subtotal).to eq(price_base * quantity)
        expect(item.total).to eq(price_base * quantity)
        expect(inventory1.reserved).to be(quantity)
        expect(inventory1.stock).to be(stock)
        expect(product.reserved).to be(inventory1.reserved)
        expect(product.stock).to be(quantity_inventory)
      end

      it "create item inside order with all stock" do
        quantity = quantity_inventory
        inventory1 = Inventory.first
        stock = inventory1.stock

        inventory2 = Inventory.where(warehouse_id: warehouse2.id).first
        stock2 = inventory2.stock

        item = OrdersItem.new(order: order, product: product, quantity: quantity)
        item.save!

        inventory1.reload
        inventory2.reload
        product.reload

        expect(item).to be_valid
        expect(item.quantity).to be(quantity)
        expect(item.price_without_tax).to eq(price_base)
        expect(item.price).to eq(price_base)
        expect(item.tax_amount).to eq(0)
        expect(item.subtotal).to eq(price_base * quantity)
        expect(item.total).to eq(price_base * quantity)

        expect(inventory1.reserved).to be(stock)
        expect(inventory1.stock).to be(stock)

        expect(inventory2.reserved).to be(stock2)
        expect(inventory2.stock).to be(stock2)
        expect(product.reserved).to be(product.stock)
        expect(product.stock).to be(quantity_inventory)
      end

      it "an item can't request to reseve a quantity greather than available" do
        quantity = quantity_inventory + 50
        inventory1 = Inventory.first
        stock = inventory1.stock

        inventory2 = Inventory.where(warehouse_id: warehouse2.id).first
        stock2 = inventory2.stock

        item = OrdersItem.new(order: order, product: product, quantity: quantity)
        item.save!

        inventory1.reload
        inventory2.reload
        product.reload

        expect(item).to be_valid
        expect(item.quantity).to be(quantity_inventory)
        expect(item.price_without_tax).to eq(price_base)
        expect(item.price).to eq(price_base)
        expect(item.tax_amount).to eq(0)
        expect(item.subtotal).to eq(price_base * quantity_inventory)
        expect(item.total).to eq(price_base * quantity_inventory)

        expect(inventory1.reserved).to be(stock)
        expect(inventory1.stock).to be(stock)

        expect(inventory2.reserved).to be(stock2)
        expect(inventory2.stock).to be(stock2)
        expect(product.reserved).to be(product.stock)
        expect(product.stock).to be(quantity_inventory)
      end
    end

    context "with product with tax" do
      let(:price_base) { 100 }
      let(:quantity_inventory) { 140 }
      let(:tax_amount) { Tax.first.percentage * price_base }
      let(:product) { Product.first || FactoryBot.create(:product_with_tax) }

      before(:each) do
        create_inventory_and_price(price_base, product, quantity_inventory)
      end

      it "an item can't have quantity zero" do
        item = OrdersItem.new(order: order, product: product, quantity: 0)
        expect(item).to_not be_valid
      end

      it "create item inside order" do
        quantity = 10
        inventory1 = Inventory.first
        stock = inventory1.stock

        item = OrdersItem.new(order: order, product: product, quantity: quantity)
        item.save!

        inventory1.reload
        product.reload
        order.reload

        expect(item).to be_valid
        expect(item.quantity).to be(quantity)
        expect(item.price_without_tax).to eq(price_base)
        expect(item.price).to eq(price_base + tax_amount)
        expect(item.tax_amount).to eq(tax_amount * quantity)
        expect(item.subtotal).to eq(price_base * quantity)
        expect(item.total).to eq((price_base + tax_amount) * quantity)
        expect(inventory1.reserved).to be(quantity)
        expect(inventory1.stock).to be(stock)
        expect(product.reserved).to be(inventory1.reserved)
        expect(product.stock).to be(quantity_inventory)

        expect(order.total).to eq(item.total)
        expect(order.tax_amount).to eq(item.tax_amount)
        expect(order.subtotal).to eq(item.subtotal)
        expect(order.products_count).to eq(1)
        expect(order.quantity_total).to eq(quantity)
      end

      it "create item inside order with all stock" do
        quantity = quantity_inventory
        inventory1 = Inventory.first
        stock = inventory1.stock

        inventory2 = Inventory.where(warehouse_id: warehouse2.id).first
        stock2 = inventory2.stock

        item = OrdersItem.new(order: order, product: product, quantity: quantity)
        item.save!

        inventory1.reload
        inventory2.reload
        product.reload
        order.reload

        expect(item).to be_valid
        expect(item.quantity).to be(quantity)
        expect(item.price_without_tax).to eq(price_base)
        expect(item.price).to eq(price_base + tax_amount)
        expect(item.tax_amount).to eq(tax_amount * quantity)
        expect(item.subtotal).to eq(price_base * quantity)
        expect(item.total).to eq((price_base + tax_amount) * quantity)

        expect(inventory1.reserved).to be(stock)
        expect(inventory1.stock).to be(stock)

        expect(inventory2.reserved).to be(stock2)
        expect(inventory2.stock).to be(stock2)
        expect(product.reserved).to be(product.stock)
        expect(product.stock).to be(quantity_inventory)

        expect(order.total).to eq(item.total)
        expect(order.tax_amount).to eq(item.tax_amount)
        expect(order.subtotal).to eq(item.subtotal)
        expect(order.products_count).to eq(1)
        expect(order.quantity_total).to eq(quantity)
      end

      it "an item can't request to reseve a quantity greather than available" do
        quantity = quantity_inventory + 50
        inventory1 = Inventory.first
        stock = inventory1.stock

        inventory2 = Inventory.where(warehouse_id: warehouse2.id).first
        stock2 = inventory2.stock

        item = OrdersItem.new(order: order, product: product, quantity: quantity)
        item.save!

        inventory1.reload
        inventory2.reload
        product.reload
        order.reload

        expect(item).to be_valid
        expect(item.quantity).to be(quantity_inventory)
        expect(item.price_without_tax).to eq(price_base)
        expect(item.price).to eq(price_base + tax_amount)
        expect(item.tax_amount).to eq(tax_amount * quantity_inventory)
        expect(item.total).to eq((price_base + tax_amount) * quantity_inventory)
        expect(item.subtotal).to eq(price_base * quantity_inventory)

        expect(inventory1.reserved).to be(stock)
        expect(inventory1.stock).to be(stock)

        expect(inventory2.reserved).to be(stock2)
        expect(inventory2.stock).to be(stock2)
        expect(product.reserved).to be(product.stock)
        expect(product.stock).to be(quantity_inventory)

        expect(order.total).to eq(item.total)
        expect(order.tax_amount).to eq(item.tax_amount)
        expect(order.subtotal).to eq(item.subtotal)
        expect(order.products_count).to eq(1)
        expect(order.quantity_total).to eq(quantity_inventory)
      end

      it "an item must save a history about inventory reserved" do
        quantity = quantity_inventory + 50
        inventory1 = Inventory.first
        stock = inventory1.stock

        inventory2 = Inventory.where(warehouse_id: warehouse2.id).first
        stock2 = inventory2.stock

        item = OrdersItem.new(order: order, product: product, quantity: quantity)
        item.save!

        inventory1.reload
        inventory2.reload

        history = ItemsInventory.where(inventory_id: inventory1.id, orders_item_id: item.id).first
        expect(history.nil?).to be(false)
        expect(history.quantity).to be(inventory1.reserved)

        history = ItemsInventory.where(inventory_id: inventory2.id, orders_item_id: item.id).first
        expect(history.nil?).to be(false)
        expect(history.quantity).to be(inventory2.reserved)
      end
    end
  end

  describe "remove item to an order" do
    let(:price_base) { 23.45 }
    let(:quantity_inventory) { 140 }
    let(:product) { Product.first || FactoryBot.create(:product_without_tax) }
    let(:item) { OrdersItem.first || OrdersItem.create!(order: order, product: product, quantity: 100) }

    before(:each) do
      create_inventory_and_price(price_base, product, quantity_inventory)
    end

    it "you only can delete an item into order when it is pending" do
      c = item

      status = OrdersStatus.where(name: ORDER_STATUSES_NAME[:invoiced]).first
      order.update(orders_status_id: status.id)
      expect { c.destroy }.to change(OrdersItem, :count).by(0)

      status = OrdersStatus.where(name: ORDER_STATUSES_NAME[:canceled]).first
      order.update(orders_status_id: status.id)
      expect { c.destroy }.to change(OrdersItem, :count).by(0)

      status = OrdersStatus.where(name: ORDER_STATUSES_NAME[:pending]).first
      order.update(orders_status_id: status.id)
      expect { c.destroy }.to change(OrdersItem, :count).by(-1)
    end

    it "item removed success on order" do
      product = item.product
      item.destroy

      product.reload
      expect(product.reserved).to eq(0)
      expect(product.stock).to eq(quantity_inventory)

      inventory1 = Inventory.first
      inventory2 = Inventory.where(warehouse_id: warehouse2.id).first
      expect(inventory1.reserved).to eq(0)
      expect(inventory2.reserved).to eq(0)

      order.reload
      expect(order.products_count).to eq(0)
      expect(order.quantity_total).to eq(0)
      expect(order.subtotal).to eq(0)
      expect(order.total).to eq(0)
      expect(order.tax_amount).to eq(0)
    end
  end
end
