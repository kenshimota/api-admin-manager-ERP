require "rails_helper"

RSpec.describe State, type: :model do
  context "validate create a state" do
    let(:name) { "Nombre Estado" }

    it "a state doesn't be void" do
      expect(State.new).to_not be_valid
    end

    it "a state doesn't be name void" do
      expect(State.create(name: nil)).to_not be_valid
      expect(State.create(name: "")).to_not be_valid
    end

    it "save state unique, it can't repeat a name" do
      expect(State.create(name: name)).to be_valid
      expect(State.create(name: name)).to_not be_valid
      expect(State.create(name: name.upcase)).to_not be_valid
    end

    it "save success" do
      expect(State.create(name: name)).to be_valid
    end
  end
end
