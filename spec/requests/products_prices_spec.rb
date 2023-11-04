require "rails_helper"

# This spec was generated by rspec-rails when you ran the scaffold generator.
# It demonstrates how one might use RSpec to test the controller code that
# was generated by Rails when you ran the scaffold generator.
#
# It assumes that the implementation code is generated by the rails scaffold
# generator. If you are using any extension libraries to generate different
# controller code, this generated spec may or may not pass.
#
# It only uses APIs available in rails and/or rspec-rails. There are a number
# of tools you can use to make these specs even more expressive, but we're
# sticking to rails and rspec-rails APIs to keep things simple and stable.

RSpec.describe "/products_prices", type: :request do
  let(:user) { User.first || FactoryBot.create(:user) }
  let(:currency) { Currency.first || FactoryBot.create(:currency) }
  let(:product_attributes) { FactoryBot.attributes_for(:product) }
  let(:product) { Product.first || Product.create!(product_attributes) }

  # This should return the minimal set of attributes required to create a valid
  # ProductsPrice. As you add validations to ProductsPrice, be sure to
  # adjust the attributes here as well.
  let(:valid_attributes) { { product_id: product.id, currency_id: currency.id, price: 1 } }
  let(:invalid_attributes) { { product_id: product.id, currency_id: currency.id, price: 0 } }

  let(:products_price) do
    products_price = ProductsPrice.new(valid_attributes)
    products_price.set_user user
    products_price.save!
    products_price
  end

  describe "GET /index" do
    before(:each) do
      n = 0
      codes = Set.new

      while n < 35
        code = Faker::Code.asin
        next if codes.include?(code)

        product = Product.new(product_attributes)
        product.code = code
        product.name = Faker::Commerce.product_name
        product.save!

        price = ProductsPrice.new(product: product, currency: currency, price: Faker::Commerce.price)
        price.set_user user
        price.save!

        codes << code
        n += 1
      end
    end

    it "a user can't see the prices only if you've signin" do
      get products_prices_url
      expect(response).to have_http_status(:unauthorized)
    end

    it "the prices  page '1'", authorized: true do
      get products_prices_url
      body = JSON.parse(response.body)

      expect(response).to have_http_status(:ok)
      expect(body.length).to be(20)
    end

    it "the prices page '2'", authorized: true do
      get products_prices_url, params: { page: 2 }
      body = JSON.parse(response.body)

      expect(response).to have_http_status(:ok)
      expect(body.length).to be(15)
    end

    it "the prices  page '1', product_id ':id'", authorized: true do
      product = Product.last
      get products_prices_url, params: { product_id: product.id }
      body = JSON.parse(response.body)
      product_price = ProductsPrice.where(product_id: product.id).first

      expect(response).to have_http_status(:ok)
      expect(body.length).to be(1)

      expect(body[0]["price"].to_f).to eq(product_price.price.to_f)
    end

    it "the prices  page '2', product_id ':id'", authorized: true do
      product = Product.last
      get products_prices_url, params: { page: 2, product_id: product.id }
      body = JSON.parse(response.body)

      product_price = ProductsPrice.where(product_id: product.id).first

      expect(response).to have_http_status(:ok)
      expect(body.length).to be(0)
    end

    it "the prices page '1', currency_id ':id'", authorized: true do
      currency = Currency.last
      get products_prices_url, params: { currency_id: currency.id }
      body = JSON.parse(response.body)

      expect(response).to have_http_status(:ok)
      expect(body.length).to be(20)
    end

    it "the prices  page '1', currency_id ':id'", authorized: true do
      currency = Currency.last
      get products_prices_url, params: { page: 2, currency_id: currency.id }
      body = JSON.parse(response.body)

      expect(response).to have_http_status(:ok)
      expect(body.length).to be(15)
    end

    it "the prices  page '1', currency_id ':id', metadata '1'", authorized: true do
      currency = Currency.last
      get products_prices_url, params: { page: 2, metadata: 1, currency_id: currency.id }
      body = JSON.parse(response.body)
      first = body.first

      expect(response).to have_http_status(:ok)
      expect(body.length).to be(15)

      expect(first["product"].nil?).to be(false)
      expect(first["currency"].nil?).to be(false)
      expect(first["tax"].nil?).to be(false)
    end

    it "the prices  search ':product_code'", authorized: true do
      product = Product.last
      get products_prices_url, params: { q: product.code.upcase }

      body = JSON.parse(response.body)

      count = ProductsPrice.where(product_id: product.id).count
      product_price = ProductsPrice.where(product_id: product.id).first

      expect(response).to have_http_status(:ok)
      expect(body.length).to be(count)
      expect(body[0]["price"].to_f).to eq(product_price.price.to_f)
    end
  end

  describe "GET /show" do
    it "a user can't see the prices only if you've signin" do
      get products_price_url(products_price), as: :json
      expect(response).to have_http_status(:unauthorized)
    end

    it "renders a successful response", authorized: true do
      get products_price_url(products_price), as: :json
      body = JSON.parse(response.body)

      expect(response).to be_successful
      expect(body["product"].nil?).to be(false)
      expect(body["currency"].nil?).to be(false)
      expect(body["tax"].nil?).to be(false)
    end
  end

  describe "POST /create" do
    context "without signin" do
      it "you can't change products prices whetter you didn't signin" do
        expect {
          post products_prices_url,
               params: { products_price: valid_attributes }
        }.to change(ProductsPrice, :count).by(0)
      end

      it "renders a JSON response with errors for you didn't signin" do
        post products_prices_url,
             params: { products_price: invalid_attributes }
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context "with valid parameters" do
      it "creates a new ProductsPrice", authorized: true do
        expect {
          post products_prices_url,
               params: { products_price: valid_attributes }
        }.to change(ProductsPrice, :count).by(1)
      end

      it "renders a JSON response with the new products_price", authorized: true do
        post products_prices_url,
             params: { products_price: valid_attributes }
        expect(response).to have_http_status(:created)
        expect(response.content_type).to match(a_string_including("application/json"))
      end
    end

    context "with invalid parameters" do
      it "does not create a new ProductsPrice", authorized: true do
        expect {
          post products_prices_url,
               params: { products_price: invalid_attributes }, as: :json
        }.to change(ProductsPrice, :count).by(0)
      end

      it "renders a JSON response with errors for the new products_price", authorized: true do
        post products_prices_url,
             params: { products_price: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.content_type).to match(a_string_including("application/json"))
      end
    end
  end

  describe "PATCH /update" do
    let(:new_attributes) { { price: 100 } }

    context "with valid parameters without you haven't signin" do
      it "trying to update product_prices" do
        patch products_price_url(products_price),
              params: { products_price: new_attributes }, as: :json

        expect(response).to have_http_status(:unauthorized)
        expect(response.content_type).to match(a_string_including("application/json"))
      end
    end

    context "with valid parameters" do
      it "updates the requested products_price", authorized: true do
        patch products_price_url(products_price),
              params: { products_price: new_attributes }

        products_price.reload
        expect(new_attributes[:price]).to eq(products_price.price)
      end

      it "renders a JSON response with the products_price", authorized: true do
        patch products_price_url(products_price),
              params: { products_price: new_attributes }

        expect(response).to have_http_status(:accepted)
        expect(response.content_type).to match(a_string_including("application/json"))
      end
    end

    context "with invalid parameters" do
      it "renders a JSON response with errors for the products_price", authorized: true do
        patch products_price_url(products_price),
              params: { products_price: { price: 0 } }
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.content_type).to match(a_string_including("application/json"))
      end
    end
  end

  describe "DELETE /destroy" do
    it "destroys the requested products_price", authorized: true do
      expect {
        delete products_price_url(products_price)
      }.to change(ProductsPrice, :count).by(0)
    end

    it "destroys the requested products_price" do
      expect {
        delete products_price_url(products_price)
      }.to change(ProductsPrice, :count).by(1)
    end
  end
end
