require "rails_helper"

RSpec.describe Product, type: :model do
  let(:params_validated) {
    {
      bar_code: "123456789011",
      code: "a524a78126A",
      name: "Product 1",
      tax: FactoryBot.create(:tax_with_percentage),
    }
  }

  context "validate create a product" do
    it "a product void" do
      expect(Product.new).to_not be_valid
    end

    it "a product won't be valid without name or the product have a name with less 3 letters" do
      data = params_validated.clone
      data[:name] = nil
      product = Product.new(data)
      expect(product).to_not be_valid

      data = params_validated.clone
      data[:name] = ""
      product = Product.new(data)
      expect(product).to_not be_valid

      data = params_validated.clone
      data[:name] = "na"
      product = Product.new(data)
      expect(product).to_not be_valid
    end

    it "a product won't be valid without code or the product have a code with less 3 letters" do
      data = params_validated.clone
      data[:code] = nil
      product = Product.new(data)
      expect(product).to_not be_valid

      data = params_validated.clone
      data[:code] = ""
      product = Product.new(data)
      expect(product).to_not be_valid

      data = params_validated.clone
      data[:code] = "na"
      product = Product.new(data)
      expect(product).to_not be_valid
    end

    it "a product won't be valid without code or the product have a code with less 3 letters" do
      data = params_validated.clone
      data[:code] = nil
      product = Product.new(data)
      expect(product).to_not be_valid

      data = params_validated.clone
      data[:code] = ""
      product = Product.new(data)
      expect(product).to_not be_valid

      data = params_validated.clone
      data[:code] = "na"
      product = Product.new(data)
      expect(product).to_not be_valid
    end

    it "a product might be valid without bar_code or the product have a code with greater 12 characters" do
      data = params_validated.clone
      data[:bar_code] = nil
      product = Product.new(data)
      expect(product).to be_valid

      data = params_validated.clone
      data[:bar_code] = ""
      product = Product.new(data)
      expect(product).to be_valid

      data = params_validated.clone
      data[:bar_code] = "na"
      product = Product.new(data)
      expect(product).to_not be_valid
    end

    it "a code of product should not repeat" do
      data = params_validated.clone
      expect(Product.create(data)).to be_valid

      data = params_validated.clone
      data[:code] = data[:code].downcase
      expect(Product.create(data)).to_not be_valid

      data = params_validated.clone
      data[:code] = data[:code].upcase
      expect(Product.create(data)).to_not be_valid
    end

    it "whether you try create a product with stock or reserved, this values changed to 0" do
      data = params_validated.clone
      data[:stock] = 12
      data[:reserved] = 12

      product = Product.create(data)

      expect(product.stock).to be(0)
      expect(product.reserved).to be(0)
    end

    it "only whether all attributes have been validated" do
      product = Product.create(params_validated)
      expect(product).to be_valid
    end
  end
end
