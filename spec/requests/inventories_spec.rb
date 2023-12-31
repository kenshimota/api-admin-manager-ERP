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

RSpec.describe "/inventories", type: :request do
  let(:user) { User.first || FactoryBot.create(:user) }
  let(:product) { Product.first || FactoryBot.create(:product) }
  let(:warehouse) { Warehouse.first || FactoryBot.create(:warehouse) }

  let(:product_attributes) {
    {
      name: "Product Temp",
      bar_code: "123456789",
      code: "Product Temp 1.1.1.1.1.1",
      tax: Tax.first || FactoryBot.create(:tax_with_percentage),
    }
  }

  let(:valid_attributes) {
    {
      stock: 10,
      reserved: 0,
      observations: "init test",
      product_id: product.id,
      warehouse_id: warehouse.id,
    }
  }

  describe "GET /index" do
    before(:each) do
      for index in 1..36
        attributes = valid_attributes.clone
        warehouse_aux = Warehouse.create!(name: "warehouse #{index}")

        attributes[:stock] = Faker::Number.rand_in_range(0, 1000)
        attributes[:warehouse_id] = warehouse_aux.id

        inventory = Inventory.new(attributes)
        inventory.set_user user
        inventory.save!
      end
    end

    it "a user can't see the inventories only if you've signin" do
      get inventories_url
      expect(response).to have_http_status(:unauthorized)
    end

    it "the inventories page '1'", authorized: true do
      get inventories_url
      body = JSON.parse(response.body)
      expect(response).to have_http_status(:ok)
      expect(body.length).to be(20)
    end

    it "the inventories page '2'", authorized: true do
      get inventories_url, params: { page: 2 }
      body = JSON.parse(response.body)

      expect(response).to have_http_status(:ok)
      expect(body.length).to be(16)
    end

    it "the inventories page '1', product_id ':id'", authorized: true do
      data = valid_attributes.clone
      product_aux = Product.create!(product_attributes)
      data[:product_id] = product_aux.id

      inventory = Inventory.new(data)
      inventory.set_user user
      inventory.save!

      get inventories_url, params: { product_id: product_aux.id }
      body = JSON.parse(response.body)

      expect(response).to have_http_status(:ok)
      expect(body.length).to be(1)
      expect(body[0]["product_id"]).to be(product_aux.id)
    end

    it "the inventories page '1', product_id ':id'", authorized: true do
      data = valid_attributes.clone
      warehouse_aux = Warehouse.create!(name: "Warehouse Temp inventory")
      data[:warehouse_id] = warehouse_aux.id

      inventory = Inventory.new(data)
      inventory.set_user user
      inventory.save!

      get inventories_url, params: { warehouse_id: warehouse_aux.id }
      body = JSON.parse(response.body)

      expect(response).to have_http_status(:ok)
      expect(body.length).to be(1)
      expect(body[0]["warehouse_id"]).to be(warehouse_aux.id)
    end

    it "the inventories page: '1', metadata: '1'", authorized: true do
      get inventories_url, params: { metadata: 1 }
      body = JSON.parse(response.body)
      first = body.first

      expect(response).to have_http_status(:ok)
      expect(first["warehouse"].nil?).to be(false)
      expect(first["product"].nil?).to be(false)
    end

    it "the inventories page: '1', q: '36'", authorized: true do
      warehouse = Warehouse.where("UPPER(name) LIKE UPPER('%first%') ").first
      product = FactoryBot.create(:product_without_tax)
      inventory = Inventory.new(product_id: product.id, warehouse_id: warehouse.id, stock: 1001, observations: "the last")
      inventory.set_user user
      inventory.save!

      get inventories_url, params: { q: "first".upcase }
      body = JSON.parse(response.body)
      first = body.first

      count = Inventory.where(warehouse: warehouse).count

      expect(response).to have_http_status(:ok)
      expect(body.length).to be(count)
    end

    it "the inventories page: '1', q: '36'", authorized: true do
      warehouse = Warehouse.last
      product = FactoryBot.create(:product_without_tax)
      inventory = Inventory.new(product_id: product.id, warehouse_id: warehouse.id, stock: 1001, observations: "the last")
      inventory.set_user user
      inventory.save!

      get inventories_url, params: { q: "without tax".upcase }
      body = JSON.parse(response.body)
      first = body.first

      expect(response).to have_http_status(:ok)
      expect(body.length).to be(1)
    end
  end

  describe "GET /show" do
    it "you can't  see a inventory if you didn't signin" do
      inventory = Inventory.new valid_attributes
      inventory.set_user user
      inventory.save!

      get inventory_url(inventory), as: :json
      expect(response).to have_http_status(:unauthorized)
    end

    it "renders a successful response", authorized: true do
      inventory = Inventory.new valid_attributes
      inventory.set_user user
      inventory.save!

      get inventory_url(inventory), as: :json
      body = JSON.parse(response.body)

      expect(response).to be_successful
      expect(body["product"].nil?).to be(false)
      expect(body["warehouse"].nil?).to be(false)
    end
  end

  describe "POST /create" do
    context "without signin" do
      it "creates a new Inventory" do
        post inventories_url, params: { inventory: valid_attributes }, as: :json
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context "with valid parameters" do
      it "creates a new Inventory", authorized: true do
        expect {
          post inventories_url,
               params: { inventory: valid_attributes }, as: :json
        }.to change(Inventory, :count).by(1)
      end

      it "renders a JSON response with the new inventory", authorized: true do
        post inventories_url,
             params: { inventory: valid_attributes }, as: :json
        expect(response).to have_http_status(:created)
        expect(response.content_type).to match(a_string_including("application/json"))
      end
    end

    context "with invalid parameters" do
      it "does not create a new Inventory", authorized: true do
        invalid_attributes = valid_attributes.clone
        invalid_attributes[:stock] = -1

        expect {
          post inventories_url,
               params: { inventory: invalid_attributes }, as: :json
        }.to change(Inventory, :count).by(0)
      end

      it "renders a JSON response with errors for the new inventory", authorized: true do
        invalid_attributes = valid_attributes.clone
        invalid_attributes[:stock] = -1

        post inventories_url,
             params: { inventory: invalid_attributes }, as: :json
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.content_type).to match(a_string_including("application/json"))
      end
    end
  end

  describe "PATCH /update" do
    context "without signin" do
      it "updates the requested inventory" do
        inventory = Inventory.new valid_attributes
        inventory.set_user user
        inventory.save!

        patch inventory_url(inventory),
              params: { inventory: valid_attributes }, as: :json

        expect(response).to have_http_status(:unauthorized)
      end
    end

    context "with valid parameters" do
      let(:new_warehouse) { Warehouse.find_or_create_by(name: "warehouse inesperado") }
      let(:new_product) { Product.find_or_create_by(product_attributes) }

      let(:new_attributes) {
        {
          stock: 100,
          observations: "update patch test",
          product_id: new_product.id,
          warehouse_id: new_warehouse.id,
        }
      }

      it "updates the requested inventory", authorized: true do
        inventory = Inventory.new valid_attributes
        inventory.set_user user
        inventory.save!

        patch inventory_url(inventory),
              params: { inventory: new_attributes }, as: :json

        inventory.reload
        history = inventory.inventories_histories.last

        expect(inventory.stock).to be(new_attributes[:stock])
        expect(inventory.product_id).to be(new_attributes[:product_id])
        expect(inventory.warehouse_id).to be(new_attributes[:warehouse_id])
        expect(history.before_amount).to be(10)
        expect(history.after_amount).to be(100)
      end

      it "renders a JSON response with the inventory", authorized: true do
        inventory = Inventory.new valid_attributes
        inventory.set_user user
        inventory.save!

        patch inventory_url(inventory),
              params: { inventory: new_attributes }, as: :json

        expect(response).to have_http_status(:accepted)
        expect(response.content_type).to match(a_string_including("application/json"))
      end
    end

    context "with invalid parameters" do
      it "renders a JSON response with errors for the inventory", authorized: true do
        inventory = Inventory.new valid_attributes
        inventory.set_user user
        inventory.save!

        invalid_attributes = valid_attributes.clone
        invalid_attributes[:stock] = -1

        patch inventory_url(inventory),
              params: { inventory: invalid_attributes }, as: :json

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.content_type).to match(a_string_including("application/json"))
      end
    end
  end

  describe "DELETE /destroy" do
    let(:inventory) do
      last = Inventory.last

      if last
        return last
      end

      current = Inventory.new valid_attributes
      current.set_user user
      current.save!

      current
    end

    context "inventory without reserved" do
      it "destroys the requested inventory" do
        delete inventory_url(inventory), as: :json
        expect(response).to have_http_status(:unauthorized)
      end

      it "destroys the requested inventory", authorized: true do
        current = inventory
        expect { delete inventory_url(current), as: :json }.to change(Inventory, :count).by(-1)
      end

      it "when delete a inventory, it must substraction stock from the product", authorized: true do
        delete inventory_url(inventory), as: :json
        product.reload

        expect(response).to have_http_status(:no_content)
        expect(product.stock).to be(0)
      end
    end

    context "inventory with reserved" do
      let(:to_reverse) { 1 }

      before(:each) do
        inventory.reserve_stock to_reverse
        product.reload
      end

      it "you can't remove inventory if this has been reserved", authorized: true do
        current = inventory
        expect { delete inventory_url(current), as: :json }.to change(Inventory, :count).by(0)
      end

      it "you can't remove inventory if this has been reserved and show error", authorized: true do
        delete inventory_url(inventory), as: :json
        current = Product.find(product.id)

        expect(response).to have_http_status(:unprocessable_entity)
        expect(current.stock).to be(product.stock)
        expect(product.reserved).to be(to_reverse)
      end
    end
  end
end
