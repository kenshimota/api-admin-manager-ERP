require "rails_helper"

RSpec.describe ProductsPrice, type: :model do
  let(:product) { Product.first || FactoryBot.create(:product) }
  let(:currency) { Currency.first || FactoryBot.create(:currency) }
  let(:valid_attributes) { { product_id: product.id, currency_id: currency.id, price: Faker::Commerce.price } }

  context "create a price" do
    it "a price doesn't be void" do
      expect(ProductsPrice.new).to_not be_valid
    end

    it "a price can't have currency_id null or void" do
      data = valid_attributes.clone
      currency_id = data[:currency_id]

      data[:currency_id] = nil
      expect(ProductsPrice.create(data)).to_not be_valid

      data[:currency_id] = ""
      expect(ProductsPrice.create(data)).to_not be_valid

      data[:currency_id] = currency_id
      expect(ProductsPrice.create(data)).to be_valid
    end

    it "a price can't have product_id null or void" do
      data = valid_attributes.clone
      product_id = data[:product_id]

      data[:product_id] = nil
      expect(ProductsPrice.create(data)).to_not be_valid

      data[:product_id] = ""
      expect(ProductsPrice.create(data)).to_not be_valid

      data[:product_id] = product_id
      expect(ProductsPrice.create(data)).to be_valid
    end

    it "a price can't be fewer or equal than zero, a price can't be null or void" do
      data = valid_attributes.clone
      price = data[:price]

      data[:price] = 0
      expect(ProductsPrice.create(data)).to_not be_valid

      data[:price] = nil
      expect(ProductsPrice.create(data)).to_not be_valid

      data[:price] = ""
      expect(ProductsPrice.create(data)).to_not be_valid

      data[:price] = price
      expect(ProductsPrice.create(data)).to be_valid
    end
  end
end
