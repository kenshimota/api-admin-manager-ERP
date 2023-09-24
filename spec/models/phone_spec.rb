require "rails_helper"

RSpec.describe Phone, type: :model do
  context "validate create a phone" do
    let(:code) { Faker::PhoneNumber.country_code.split("+").last.to_i }
    let(:number) { Faker::PhoneNumber.cell_phone_in_e164.split("+").last.reverse.slice(0, 10).reverse.to_i }

    it "a phone doesn't be void" do
      expect(Phone.new).to_not be_valid
    end

    it "a phone can't a field void" do
      expect(Phone.new(prefix: code)).to_not be_valid
      expect(Phone.new(number: number)).to_not be_valid
    end

    it "a phone can't be repeated" do
      expect(Phone.create(prefix: code, number: number)).to be_valid
      expect(Phone.create(prefix: code, number: number)).to_not be_valid

      new_code = code == 999 ? code - 1 : code + 1
      expect(Phone.create(prefix: new_code + 1, number: number)).to be_valid
    end
  end
end
