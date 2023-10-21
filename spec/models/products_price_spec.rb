require "rails_helper"

RSpec.describe ProductsPrice, type: :model do
  let(:product) { Product.first || FactoryBot.create(:product) }
  let(:currency) { Currency.first || FactoryBot.create(:currency) }
  let(:current_user) { User.first || FactoryBot.create(:user) }
  let(:valid_attributes) { { product_id: product.id, currency_id: currency.id, price: Faker::Commerce.price } }

  context "create a price" do
    it "a price doesn't be void" do
      expect(ProductsPrice.new).to_not be_valid
    end

    it "a price can't have currency_id null or void" do
      data = valid_attributes.clone
      currency_id = data[:currency_id]

      data[:currency_id] = nil
      expect(ProductsPrice.new(data)).to_not be_valid

      data[:currency_id] = ""
      expect(ProductsPrice.new(data)).to_not be_valid

      data[:currency_id] = currency_id
      expect(ProductsPrice.new(data)).to be_valid
    end

    it "a price can't have product_id null or void" do
      data = valid_attributes.clone
      product_id = data[:product_id]

      data[:product_id] = nil
      expect(ProductsPrice.new(data)).to_not be_valid

      data[:product_id] = ""
      expect(ProductsPrice.new(data)).to_not be_valid

      data[:product_id] = product_id
      expect(ProductsPrice.new(data)).to be_valid
    end

    it "a price can't be fewer or equal than zero, a price can't be null or void" do
      product_price = ProductsPrice.new(valid_attributes)
      price = product_price.price

      product_price.price = 0
      expect(product_price).to_not be_valid

      product_price.price = nil
      expect(product_price).to_not be_valid

      product_price.price = ""
      expect(product_price).to_not be_valid

      product_price.price = price
      expect(product_price).to be_valid
    end

    it "a price can't be repeat" do
      product_price_1 = ProductsPrice.new(valid_attributes)
      product_price_1.set_user current_user
      product_price_1.save!
      expect(product_price_1).to be_valid

      product_price_2 = ProductsPrice.new(valid_attributes)
      product_price_2.set_user current_user
      expect(product_price_2).to_not be_valid

      expect(product_price_1.products_prices_histories.length).to be(1)
    end
  end

  context "update a price price" do
    let(:product_price) {
      p = ProductsPrice.new(valid_attributes)
      p.set_user current_user
      p.save!
      p
    }

    it "trying to update field price with same value" do
      resource = product_price
      prev_price = resource.price
      new_price = prev_price + 0

      expect(resource).to be_valid

      resource.update(price: new_price)
      history = resource.products_prices_histories.last

      expect(history.price_before).to eq(0.0)
      expect(history.price_after).to eq(new_price)
    end

    it "update a field price" do
      resource = product_price
      prev_price = resource.price
      new_price = prev_price + 1

      expect(resource).to be_valid

      resource.update(price: new_price)
      history = resource.products_prices_histories.last

      expect(resource.products_prices_histories.length).to be(2)
      expect(history.price_before).to eq(prev_price)
      expect(history.price_after).to eq(new_price)
    end
  end
end
