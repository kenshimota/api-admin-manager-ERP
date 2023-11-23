require "rails_helper"

RSpec.describe "Passwords", type: :request do
  describe "create code to reset password" do
    let(:user) { FactoryBot.create(:user) || User.first }

    context "Success" do
      it "send code" do
        post reset_passwords_url, params: { user: { email: user.email } }
        body = JSON.parse(response.body)

        current_user = User.find_by(email: user.email)

        expect(current_user.reset_code.nil?).to be(false)
        expect(current_user.reset_code_sent_at.nil?).to be(false)
      end
    end
  end

  describe "update password" do
    let(:code) { 123456 }
    let(:password) { "managEr1." }
    let(:user) { FactoryBot.create(:user) || User.first }

    before(:each) do
      user.update!(reset_code: code, reset_code_sent_at: Time.now.utc)
    end

    context "Invalid" do
      it "send code invalid" do
        put reset_passwords_url, params: { user: { email: user.email, reset_code: code + 1, password: password } }
        current_user = User.find_by(email: user.email)

        expect(current_user.reset_code.nil?).to be(false)
        expect(current_user.reset_code_sent_at.nil?).to be(false)
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "send code expired" do
        user.update!(reset_code_sent_at: Time.now.utc - 2.hour)
        put reset_passwords_url, params: { user: { email: user.email, reset_code: code, password: password } }
        current_user = User.find_by(email: user.email)

        expect(current_user.reset_code.nil?).to be(false)
        expect(current_user.reset_code_sent_at.nil?).to be(false)
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "send password invalid" do
        put reset_passwords_url, params: { user: { email: user.email, reset_code: code + 1, password: password.downcase } }
        current_user = User.find_by(email: user.email)

        expect(current_user.reset_code.nil?).to be(false)
        expect(current_user.reset_code_sent_at.nil?).to be(false)
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context "Success" do
      it "update password" do
        put reset_passwords_url, params: { user: { email: user.email, reset_code: code, password: password } }
        current_user = User.find_by(email: user.email)

        expect(current_user.reset_code.nil?).to be(true)
        expect(current_user.reset_code_sent_at.nil?).to be(true)
        expect(response).to have_http_status(:accepted)
      end
    end
  end
end
