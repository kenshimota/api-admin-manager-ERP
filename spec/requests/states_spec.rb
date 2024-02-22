require "rails_helper"

RSpec.describe "States", type: :request do
  context "Request without token" do
    describe "GET states/" do
      it "request without query params" do
        get states_path
        expect(response).to have_http_status(:ok)
      end
    end
  end

  describe "Request with token" do
    before(:each) do
      @user = FactoryBot.create(:user)
      sign_in @user
    end

    context "GET /states" do
      before(:each) do
        states = ["Amazonas", "Anzoátegui", "Apure", "Aragua", "Barinas", "Bolívar",
                  "Carabobo", "Cojedes", "Delta Amacuro", "Dependencias Federales",
                  "Distrito Federal", "Falcón", "Guárico", "Lara", "Mérida", "Miranda",
                  "Monagas", "Nueva Esparta", "Portuguesa", "Sucre", "Táchira",
                  "Trujillo", "Vargas", "Yaracuy", "Zulia"]

        states.each do |state_name|
          State.create(name: state_name)
        end

        FactoryBot.create(:state)
      end

      it "request without query params" do
        get states_path
        body = JSON.parse(response.body)

        expect(response).to have_http_status(200)
        expect(body.length).to be(20)
      end

      it "request with query params page '2'" do
        get states_path, params: { page: 2 }
        body = JSON.parse(response.body)

        expect(response).to have_http_status(200)
        expect(body.length).to be(6)
      end

      it "request with query param q 'boliv' and page 1" do
        get states_path, params: { q: "statenam" }
        body = JSON.parse(response.body)

        expect(response).to have_http_status(200)
        expect(body.length).to be(1)
      end

      it "request with query param q 'Boliv' and page 2" do
        get states_path, params: { q: "statenam", page: 2 }
        body = JSON.parse(response.body)

        expect(response).to have_http_status(200)
        expect(body.length).to be(0)
      end
    end
  end
end
