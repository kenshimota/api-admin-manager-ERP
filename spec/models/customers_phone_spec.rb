require "rails_helper"

RSpec.describe CustomersPhone, type: :model do
  context "validate create a customer phone" do
    let(:phone) { FactoryBot.create(:phone) }
    let(:customer) { FactoryBot.create(:customer) }

    it "a customer phone doesn't be void" do
      expect(CustomersPhone.new).to_not be_valid
    end

    it "a customer phone can't a field void" do
      expect(CustomersPhone.new(phone: phone)).to_not be_valid
      expect(CustomersPhone.new(customer: customer)).to_not be_valid
    end

    it "a customer phone can't be repeated" do
      expect(CustomersPhone.create(phone: phone, customer: customer)).to be_valid
      expect(CustomersPhone.create(phone: phone, customer: customer)).to_not be_valid
    end
  end
end
