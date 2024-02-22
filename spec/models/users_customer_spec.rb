require 'rails_helper'

RSpec.describe UsersCustomer, type: :model do
  let(:customer) { Customer.first || FactoryBot.create(:customer) }  
  let(:user) { User.first || FactoryBot.create(:user) }

  context "validate create a users_customer" do
    it "a users_customer doesn't be void" do
      expect(UsersCustomer.new).to_not be_valid
    end

    it "a users_customer can't a field void" do
      expect(UsersCustomer.new(customer: customer)).to_not be_valid
      expect(UsersCustomer.new(user: user)).to_not be_valid
    end

    it "a users_customer can't be repeated" do
      expect(UsersCustomer.create(customer: customer, user: user)).to be_valid
      expect(UsersCustomer.create(customer: customer, user: user)).to_not be_valid
    end
  end
end
