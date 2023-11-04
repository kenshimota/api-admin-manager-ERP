require "rails_helper"

RSpec.describe "Taxes", type: :request do
  context "Request without token" do
    describe "GET taxes/" do
      it "request without query params" do
        get taxes_path
        expect(response).to have_http_status(:unauthorized)
      end
    end

    describe "GET taxes/" do
      it "request without query params" do
        get taxes_path
        expect(response).to have_http_status(:unauthorized)
      end
    end

    describe "POST taxes/" do
      it "request without query params" do
        get taxes_path
        expect(response).to have_http_status(:unauthorized)
      end
    end

    describe "PUT taxes/:id" do
      it "request without query params" do
        tax = FactoryBot.create(:tax_without_percentage)
        put tax_path(tax), params: { tax: { name: "new name", percentage: 0.99 } }
        expect(response).to have_http_status(:unauthorized)
      end
    end

    describe "DELETE taxes/:id" do
      it "request without query params" do
        tax = FactoryBot.create(:tax_without_percentage)
        delete tax_path(tax)
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  context "Request with token" do
    before(:each) do
      @user = FactoryBot.create(:user)
      sign_in @user
    end

    describe "GET /taxes" do
      before(:all) do
        n = 0
        while n <= 33
          percentage = (n.to_f + 1) / 100
          a = Tax.create(name: "Impuesto #{n + 1}", percentage: percentage)
          n += 1
        end
      end

      after(:all) do
        n = 0
        while n <= 33
          percentage = (n.to_f + 1) / 100
          a = Tax.destroy_by(name: "Impuesto #{n + 1}", percentage: percentage)
          n += 1
        end
      end

      before(:each) do
        FactoryBot.create(:tax_without_percentage)
      end

      it "request without query params" do
        get taxes_path
        body = JSON.parse(response.body)

        expect(response).to have_http_status(200)
        expect(body.length).to be(20)
      end

      it "request with query params page '2'" do
        get taxes_path, params: { page: 2 }
        body = JSON.parse(response.body)

        expect(response).to have_http_status(200)
        expect(body.length).to be(15)
      end

      it "request with query param q 'Tax'" do
        get taxes_path, params: { q: "Tax" }
        body = JSON.parse(response.body)

        expect(response).to have_http_status(200)
        expect(body.length).to be(1)
      end

      it "request with query param q 'IMPUESTO 1'" do
        get taxes_path, params: { q: "IMPUESTO 1" }
        body = JSON.parse(response.body)

        expect(response).to have_http_status(200)
        expect(body.length).to be(11)
      end
    end

    describe "POST /taxes" do
      it "send params errors" do
        post taxes_path, params: { tax: { name: "", percentage: 1.01 } }
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "trying save a tax with name repeat" do
        tax = FactoryBot.create(:tax_without_percentage)
        post taxes_path, params: { tax: { name: tax.name, percentage: 0.2 } }
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "trying save a tax with percentage repeat" do
        tax = FactoryBot.create(:tax_without_percentage)
        post taxes_path, params: { tax: { name: "Other name", percentage: tax.percentage } }
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "success" do
        post taxes_path, params: { tax: { name: "impuesto 99", percentage: 0.99 } }
        last = Tax.last

        expect(response).to have_http_status(:created)
        expect(JSON.parse(response.body)).to eq(JSON.parse(last.to_json))
      end
    end

    describe "PUT /taxes/:id" do
      let(:tax) { FactoryBot.create(:tax_without_percentage) }

      it "send params errors" do
        put tax_path(tax), params: { tax: { name: "", percentage: 1.01 } }
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "trying save a tax with name repeat" do
        tax2 = FactoryBot.create(:tax_with_percentage)
        put tax_path(tax), params: { tax: { name: tax2.name, percentage: 0.45 } }
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "trying save a tax with percentage repeat" do
        tax2 = FactoryBot.create(:tax_with_percentage)
        put tax_path(tax), params: { tax: { name: "Other name", percentage: tax2.percentage } }
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "ok" do
        put tax_path(tax), params: { tax: { name: "impuesto 99", percentage: 0.99 } }
        expect(response).to have_http_status(:accepted)
      end
    end

    describe "DELETE /taxes/:id" do
      let(:tax) { FactoryBot.create(:tax_without_percentage) }

      it "tax delete success" do
        delete tax_path(tax)
        expect(response).to have_http_status(:no_content)
      end
    end
  end
end
