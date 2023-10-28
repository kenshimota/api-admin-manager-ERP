require "rails_helper"

RSpec.describe InventoriesHistory, type: :model do
  context "validate create a history" do
    let(:user) { FactoryBot.create(:user) }
    let(:inventory) do
      inventory = Inventory.new(
        stock: 10,
        reserved: 0,
        observations: "init test",
        product: FactoryBot.create(:product),
        warehouse: FactoryBot.create(:warehouse),
      )

      inventory.set_user user
      inventory.save
      return inventory
    end

    let(:params_validated) {
      {
        user_id: user.id,
        after_amount: 0,
        before_amount: 0,
        inventory_id: inventory.id,
        observations: "Observations",
      }
    }

    it "a history doesn't be void" do
      expect(InventoriesHistory.new).to_not be_valid
    end

    it "a history doesn't be user_id void" do
      data = params_validated.clone
      data[:user_id] = nil
      expect(InventoriesHistory.create(data)).to_not be_valid
    end

    it "a history doesn't be inventory_id void" do
      data = params_validated.clone
      data[:inventory_id] = nil
      expect(InventoriesHistory.create(data)).to_not be_valid
    end

    it "a history can't have a before_amount and after_amount could'n fewer than 0" do
      data = params_validated.clone

      data[:before_amount] = -1
      expect(InventoriesHistory.create(data)).to_not be_valid

      data[:before_amount] = 10
      data[:after_amount] = -1
      expect(InventoriesHistory.create(data)).to_not be_valid
    end

    it "save success" do
      data = params_validated.clone
      expect(InventoriesHistory.create(data)).to be_valid
    end
  end
end
