require "rails_helper"

RSpec.describe Warehouse, type: :model do
  context "validate create a warehouse" do
    let(:name) { Faker::Commerce.department }
    let(:address) { Faker::Address.street_address }

    it "a warehouse doesn't be void" do
      expect(Warehouse.new).to_not be_valid
    end

    it "a warehouse doesn't be name void" do
      expect(Warehouse.create(name: nil, address: address)).to_not be_valid
      expect(Warehouse.create(name: "", address: address)).to_not be_valid
    end

    it "a warehouse can have an address void or string" do
      expect(Warehouse.new(name: name, address: "")).to be_valid
      expect(Warehouse.new(name: name, address: nil)).to be_valid
      expect(Warehouse.new(name: name, address: address)).to be_valid
    end

    it "save warehouse unique, it can't repeat its name" do
      expect(Warehouse.create(name: name, address: address)).to be_valid
      expect(Warehouse.create(name: name, address: address)).to_not be_valid
      expect(Warehouse.create(name: name.upcase, address: address)).to_not be_valid
    end

    it "save success" do
      expect(Warehouse.create(name: name, address: address)).to be_valid
    end
  end
end
