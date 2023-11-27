require "rails_helper"

RSpec.describe Inventory, type: :model do
  let(:product) do
    product = Product.first

    if product
      return product
    end

    FactoryBot.create(:tax_with_percentage)
    FactoryBot.create(:product)
  end

  let(:user) do
    user = User.first

    if user
      return user
    end

    FactoryBot.create(:user)
  end

  let(:warehouse) do
    warehouse = Warehouse.first

    if warehouse
      return warehouse
    end

    FactoryBot.create(:warehouse)
  end

  let(:params_validated) {
    {
      stock: 10,
      product_id: product.id,
      warehouse_id: warehouse.id,
    }
  }

  context "new a inventory" do
    it "the reserved won't be greater than stock in a inventory" do
      data = params_validated.clone
      data[:reserved] = data[:stock] + 1
      inventory = Inventory.new(data)
      expect(inventory).to_not be_valid
    end

    it "the reserved won't be fewer than 0 in a inventory" do
      data = params_validated.clone
      data[:reserved] = -1
      inventory = Inventory.new(data)
      expect(inventory).to_not be_valid
    end

    it "the stock won't be fewer than 0 in a inventory" do
      data = params_validated.clone
      data[:stock] = -1
      inventory = Inventory.new(data)
      expect(inventory).to_not be_valid
    end
  end

  context "create a inventory" do
    it "success create a inventory" do
      stock = product.stock

      inventory = Inventory.new(params_validated)
      inventory.set_user user
      expect(inventory).to be_valid

      inventory.save
      product = Product.last

      inventories_history = InventoriesHistory.last
      expect(stock + params_validated[:stock]).to be(product.stock)
      expect(inventories_history.inventory_id).to be(inventory.id)
    end
  end

  context "increment reserved and stock a inventory" do
    let(:inventory) do
      first = Inventory.first

      return first if first.nil? == false

      inventory = Inventory.new(params_validated)
      inventory.set_user user
      inventory.save
      return inventory
    end

    it "the reserved won't be greater than stock in a product" do
      amount = inventory.stock + 1
      inventory.reserve_stock amount
      expect(inventory.errors.present?).to be(true)
    end

    it "the reserved won't be fewer than 0 in a product" do
      amount = (inventory.stock + 1) * (-1)
      inventory.reserve_stock amount
      expect(inventory.errors.present?).to be(true)
    end

    it "success increment the reserved" do
      amount = inventory.stock
      inventory.reserve_stock amount
      product = Product.find(inventory.product_id)
      inventory.reload
      product.reload

      expect(inventory).to be_valid
      expect(product.stock).to be(inventory.stock)
      expect(product.reserved).to be(inventory.reserved)
      expect(product.created_at).to_not eq(product.updated_at)
      expect(inventory.created_at).to_not eq(inventory.updated_at)
    end

    it "the stock won't be fewer than 0 in a product" do
      amount = (inventory.stock + 1) * (-1)
      inventory.set_user user
      inventory.increment_stock amount
      expect(inventory).to_not be_valid
    end

    it "success increment the stock" do
      amount = inventory.stock
      inventory.set_user user

      inventory.increment_stock amount
      product = Product.find(inventory.product_id)
      history = InventoriesHistory.last
      inventory.reload

      expect(inventory).to be_valid
      expect(20).to be(inventory.stock)
      expect(0).to be(inventory.reserved)
      expect(history.inventory_id).to be(inventory.id)
      expect(history.before_amount).to be(amount)
      expect(history.after_amount).to be(inventory.stock)
      expect(product.created_at).to_not eq(product.updated_at)
      expect(inventory.created_at).to_not eq(inventory.updated_at)
    end
  end
end
