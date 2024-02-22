require "rails_helper"

RSpec.describe "Cities", type: :request do
  context "Request without token" do
    describe "GET cities/" do
      it "request without query params" do
        get cities_path
        expect(response).to have_http_status(:ok)
      end
    end
  end

  context "Request with token" do
    before(:each) do
      @user = FactoryBot.create(:user)
      sign_in @user
    end

    describe "GET /cities" do
      before(:each) do
        cities = [
          "Caracas", "Maracaibo", "Valencia", "Barquisimeto", "Maracay",
          "Ciudad Guayana", "Maturín", "Barinas", "San Cristóbal", "Ciudad Bolívar",
          "Barcelona", "Cumaná", "Cabimas", "Mérida", "Puerto La Cruz", "Guatire", "Ciudad Ojeda",
          "Punto Fijo", "Coro", "Turmero", "Los Teques", "Guanare", "Tocuyito", "San Felipe", "Acarigua",
          "Carora", "El Tigre", "Guarenas", "Cabudare", "Carúpano", "San Fernando de Apure", "Guacara", "Puerto Cabello",
          "Valera", "La Victoria", "Los Guayos", "Santa Rita", "Güigüe", "Anaco", "San Juan de los Morros",
          "El Vigía", "Palo Negro", "San Carlos", "Mariara", "Villa de Cura", "Ocumare del Tuy", "Yaritagua",
          "Cúa", "Araure", "Calabozo", "Táriba", "Guasdualito", "Puerto Ayacucho", "Machiques", "Cagua", "Porlamar",
          "Charallave", "La Asunción", "Valle de la Pascua", "Santa Lucía", "Trujillo", "Quíbor", "Tinaquillo",
          "Puerto Píritu", "El Limón", "Socopó", "Boconó", "Punta de Mata", "Ejido", "Upata", "Rubio", "Caja Seca",
          "Catia La Mar", "Tumeremo", "Caripito", "La Grita", "Santa Bárbara del Zulia", "Tucupita",
          "San José de Guanipa", "Chivacoa", "Lechería", "Zaraza", "Nirgua", "", "Santa Rita", "Guanta",
          "Morón", "Pariaguán", "San Juan de Colón", "San Joaquín", "San Antonio de los Altos", "Caicara del Orinoco",
          "Achaguas", "Biruaca", "Santa Bárbara (Barinas)", "La Guaira", "Bachaquero",
        ]
        cities.each do |city_name|
          City.create(name: city_name)
        end
        FactoryBot.create(:city)
      end

      it "request without query params" do
        get cities_path
        body = JSON.parse(response.body)

        expect(response).to have_http_status(200)
        expect(body.length).to be(20)
      end

      it "request with query params page '2'" do
        get cities_path, params: { page: 2 }
        body = JSON.parse(response.body)

        expect(response).to have_http_status(200)
        expect(body.length).to be(20)
      end

      it "request with query params page '5'" do
        get cities_path, params: { page: 5 }
        body = JSON.parse(response.body)
        expect(response).to have_http_status(200)
        expect(body.length).to be(16)
      end

      it "request with query param q 'citynam' and page 1" do
        get cities_path, params: { q: "citynam" }
        body = JSON.parse(response.body)

        expect(response).to have_http_status(200)
        expect(body.length).to be(1)
      end

      it "request with query param q 'citynam' and page 2" do
        get cities_path, params: { q: "citynam", page: 2 }
        body = JSON.parse(response.body)

        expect(response).to have_http_status(200)
        expect(body.length).to be(0)
      end
    end
  end
end
