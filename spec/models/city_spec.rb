require "rails_helper"

RSpec.describe City, type: :model do
  context "validate create a city" do
    let(:name) { "Nombre Estado" }

    it "a city doesn't be void" do
      expect(City.new).to_not be_valid
    end

    it "a city doesn't be name void" do
      expect(City.create(name: nil)).to_not be_valid
      expect(City.create(name: "")).to_not be_valid
    end

    it "save city unique, it can't repeat a name" do
      expect(City.create(name: name)).to be_valid
      expect(City.create(name: name)).to_not be_valid
      expect(City.create(name: name.upcase)).to_not be_valid
    end

    it "save success" do
      expect(City.create(name: name)).to be_valid
    end
  end
end
