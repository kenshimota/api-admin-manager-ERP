require "faker"
require "rails_helper"

RSpec.describe UsersRole, type: :model do
  let(:role) { Role.first || FactoryBot.create(:role_manager) }  
  let(:user) { User.first || FactoryBot.create(:user) }

  context "validate create a users_role" do
    it "a users_role doesn't be void" do
      expect(UsersRole.new).to_not be_valid
    end

    it "a users_role can't a field void" do
      expect(UsersRole.new(role: role)).to_not be_valid
      expect(UsersRole.new(user: user)).to_not be_valid
    end

    it "a users_role can't be repeated" do
      expect(UsersRole.create(role: role, user: user)).to be_valid
      expect(UsersRole.create(role: role, user: user)).to_not be_valid
    end
  end
end