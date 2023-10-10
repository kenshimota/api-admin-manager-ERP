require "rails_helper"

RSpec.describe Tax, type: :model do
  context "validate create a tax" do
    let(:name) { "Sin Impuesto" }
    let(:percentage) { 0.00 }

    it "a tax doesn't be void" do
      expect(Tax.new).to_not be_valid
    end

    it "a tax doesn't be name void" do
      expect(Tax.create(name: nil, percentage: percentage)).to_not be_valid
      expect(Tax.create(name: "", percentage: percentage)).to_not be_valid
    end

    it "a tax can't be percentage negative or be greater than 1" do
      expect(Tax.create(name: name, percentage: -0.1)).to_not be_valid
      expect(Tax.create(name: name, percentage: 1.01)).to_not be_valid
      expect(Tax.create(name: name, percentage: 1.00)).to be_valid
    end

    it "save role unique, it can't repeat a percentage or name" do
      expect(Tax.create(name: name, percentage: percentage)).to be_valid
      expect(Tax.create(name: name, percentage: percentage)).to_not be_valid
      expect(Tax.create(name: name.upcase, percentage: percentage)).to_not be_valid
      expect(Tax.create(name: Faker::App.name, percentage: percentage)).to_not be_valid
    end

    it "save success" do
      expect(Tax.create(name: name, percentage: percentage)).to be_valid
    end
  end
end
