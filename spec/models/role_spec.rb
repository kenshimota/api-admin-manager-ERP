require "rails_helper"

RSpec.describe Role, type: :model do
  context "validate create a role" do
    it "a role doesn't be void" do
      expect(Role.new).to_not be_valid
    end

    it "a role doesn't be name void" do
      expect(Role.create(name: nil)).to_not be_valid
      expect(Role.create(name: "")).to_not be_valid
    end

    it "save role unique" do
      name = "name-role-1"
      expect(Role.create(name: name)).to be_valid
      expect(Role.create(name: name)).to_not be_valid
      expect(Role.create(name: name.upcase)).to_not be_valid
    end
  end
end