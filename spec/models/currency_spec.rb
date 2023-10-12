require "rails_helper"

RSpec.describe Currency, type: :model do
  context "validate create a currency" do
    let(:name) { "Bolivares Venezolanos" }
    let(:code) { "VES" }
    let(:valid_attributes) {
      {
        code: code,
        symbol: "Bs",
        exchange_rate: 1,
        name: name,
      }
    }

    it "a currency doesn't be void" do
      expect(Currency.new).to_not be_valid
    end

    it "a currency doesn't be name void" do
      data = valid_attributes.clone
      data[:name] = nil
      expect(Currency.new(data)).to_not be_valid

      data[:name] = ""
      expect(Currency.new(data)).to_not be_valid
    end

    it "a currency doesn't be code void" do
      data = valid_attributes.clone
      data[:code] = nil
      expect(Currency.new(data)).to_not be_valid

      data[:code] = ""
      expect(Currency.new(data)).to_not be_valid
    end

    it "a currency doesn't be symbol void" do
      data = valid_attributes.clone
      data[:symbol] = nil
      expect(Currency.new(data)).to_not be_valid

      data[:symbol] = ""
      expect(Currency.new(data)).to_not be_valid
    end

    it "a currency doesn't be exchange_rate void and exchange_rate must be greater than zero" do
      data = valid_attributes.clone
      data[:exchange_rate] = nil
      expect(Currency.new(data)).to_not be_valid

      data[:exchange_rate] = ""
      expect(Currency.new(data)).to_not be_valid

      data[:exchange_rate] = 0
      expect(Currency.new(data)).to_not be_valid

      data[:exchange_rate] = -1
      expect(Currency.new(data)).to_not be_valid

      data[:exchange_rate] = 0.01
      expect(Currency.new(data)).to be_valid
    end

    it "a currency doesn't be code void" do
      data = valid_attributes.clone
      data[:code] = nil
      expect(Currency.new(data)).to_not be_valid

      data[:code] = ""
      expect(Currency.new(data)).to_not be_valid
    end

    it "save currency unique, it can't repeat a name" do
      data = valid_attributes.clone
      expect(Currency.create(data)).to be_valid

      data[:code] = "PPT"
      data[:name] = name.downcase
      expect(Currency.create(data)).to_not be_valid

      data[:code] = "PPP"
      data[:name] = name.upcase
      expect(Currency.create(data)).to_not be_valid
    end

    it "save currency unique, it can't repeat a code" do
      data = valid_attributes.clone
      expect(Currency.create(data)).to be_valid

      data[:code] = code.downcase
      data[:name] = "name2"
      expect(Currency.create(data)).to_not be_valid

      data[:code] = code.upcase
      data[:name] = "name3"
      expect(Currency.create(data)).to_not be_valid
    end

    it "save success" do
      expect(Currency.create(valid_attributes)).to be_valid
    end
  end
end
