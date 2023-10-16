require "rails_helper"

RSpec.describe ProductsPricesHistoriesController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(get: "/products_prices_histories").to route_to("products_prices_histories#index")
    end

    it "routes to #show" do
      expect(get: "/products_prices_histories/1").to route_to("products_prices_histories#show", id: "1")
    end


    it "routes to #create" do
      expect(post: "/products_prices_histories").to route_to("products_prices_histories#create")
    end

    it "routes to #update via PUT" do
      expect(put: "/products_prices_histories/1").to route_to("products_prices_histories#update", id: "1")
    end

    it "routes to #update via PATCH" do
      expect(patch: "/products_prices_histories/1").to route_to("products_prices_histories#update", id: "1")
    end

    it "routes to #destroy" do
      expect(delete: "/products_prices_histories/1").to route_to("products_prices_histories#destroy", id: "1")
    end
  end
end
