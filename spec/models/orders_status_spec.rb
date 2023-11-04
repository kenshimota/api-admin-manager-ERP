require "rails_helper"

RSpec.describe OrdersStatus, type: :model do
  context "validate create a status" do
    it "a status doesn't be void" do
      expect(OrdersStatus.new).to_not be_valid
    end

    it "a status doesn't be name void" do
      expect(OrdersStatus.create(name: nil)).to_not be_valid
      expect(OrdersStatus.create(name: "")).to_not be_valid
    end

    it "save status unique" do
      name = "name-role-1"
      expect(OrdersStatus.create(name: name)).to be_valid
      expect(OrdersStatus.create(name: name)).to_not be_valid
      expect(OrdersStatus.create(name: name.upcase)).to_not be_valid
    end
  end
end
