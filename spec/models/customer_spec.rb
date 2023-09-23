require "rails_helper"

RSpec.describe Customer, type: :model do
  let(:name) do
    str = ""

    while str.length < 3
      str = Faker::Name.first_name
    end

    str
  end

  let(:last_name) do
    str = ""

    while str.length < 3
      str = Faker::Name.last_name
    end

    str
  end

  let(:identity_document) { Faker::Number.number(digits: 10) }
  let(:customer_data) {
    {
      name: name,
      last_name: last_name,
      identity_document: identity_document,
      address: Faker::Address.street_address,
      state: FactoryBot::create(:state),
      city: FactoryBot::create(:city),
    }
  }

  context "validate create a customer" do
    it "a customer void" do
      expect(Customer.new).to_not be_valid
    end

    it "a customer won't be valid without name or the customer have a first_name with less 3 letters" do
      data = customer_data.clone
      data[:name] = nil
      customer = Customer.new(data)
      expect(customer).to_not be_valid

      data = customer_data.clone
      data[:name] = ""
      customer = Customer.new(data)
      expect(customer).to_not be_valid

      data = customer_data.clone
      data[:name] = "na"
      customer = Customer.new(data)
      expect(customer).to_not be_valid
    end

    it "a customer won't be valid without last_name or the customer have a last_name with less 3 letters" do
      data = customer_data.clone
      data[:last_name] = nil
      customer = Customer.new(data)
      expect(customer).to_not be_valid

      data = customer_data.clone
      data[:last_name] = ""
      customer = Customer.new(data)
      expect(customer).to_not be_valid

      data = customer_data.clone
      data[:last_name] = "na"
      customer = Customer.new(data)
      expect(customer).to_not be_valid
    end

    it "a customer won't be valid without identity_document or the customer have a identity_document with less 6 digits" do
      data = customer_data.clone
      data[:identity_document] = nil
      customer = Customer.new(data)
      expect(customer).to_not be_valid

      data = customer_data.clone
      data[:identity_document] = 1234
      customer = Customer.new(data)
      expect(customer).to_not be_valid
    end

    it "a customer won't be valid if his document identity has been registered" do
      data = customer_data.clone
      customer = Customer.create(data)
      expect(customer).to be_valid

      new_data = data.clone
      new_data[:name] = Faker::Name.first_name
      new_data[:last_name] = Faker::Name.last_name
      customer = Customer.create(new_data)
      expect(customer).to_not be_valid
    end

    it "only whether all attributes have been validated" do
      customer = Customer.create(customer_data)
      expect(customer).to be_valid
    end
  end
end
