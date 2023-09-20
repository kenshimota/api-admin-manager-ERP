require "rails_helper"

RSpec.describe User, type: :model do
  let(:first_name) do
    str = ""

    while str.length < 3
      str = Faker::Name.first_name
    end

    str
  end

  let(:last_name) do
    str = ""

    while str.length < 3
      str = Faker::Name.last_name
    end

    str
  end

  let(:password) { "Manag3r." }
  let(:email) { Faker::Internet.email }
  let(:username) do
    str = ""

    while str.length < 3
      str = Faker::Internet.user_name
    end

    str
  end

  let(:identity_document) { Faker::Number.number(digits: 10) }
  let(:user_data) { { username: username, password: password, identity_document: identity_document, last_name: last_name, first_name: first_name, email: email } }

  context "validate create a user" do
    it "a user void" do
      expect(User.new).to_not be_valid
    end

    it "a user won't be valid without first_name or the user have a first_name with less 3 letters" do
      data = user_data.clone
      data[:first_name] = nil
      user = User.new(data)
      expect(user).to_not be_valid

      data = user_data.clone
      data[:first_name] = ""
      user = User.new(data)
      expect(user).to_not be_valid

      data = user_data.clone
      data[:first_name] = "na"
      user = User.new(data)
      expect(user).to_not be_valid
    end

    it "a user won't be valid without last_name or the user have a last_name with less 3 letters" do
      data = user_data.clone
      data[:last_name] = nil
      user = User.new(data)
      expect(user).to_not be_valid

      data = user_data.clone
      data[:last_name] = ""
      user = User.new(data)
      expect(user).to_not be_valid

      data = user_data.clone
      data[:last_name] = "na"
      user = User.new(data)
      expect(user).to_not be_valid
    end

    it "a user won't be valid without username or the user have a username with less 3 letters" do
      data = user_data.clone
      data[:username] = nil
      user = User.new(data)
      expect(user).to_not be_valid

      data = user_data.clone
      data[:username] = ""
      user = User.new(data)
      expect(user).to_not be_valid

      data = user_data.clone
      data[:username] = "na"
      user = User.new(data)
      expect(user).to_not be_valid
    end

    it "a user won't be valid without identity_document or the user have a identity_document with less 6 digits" do
      data = user_data.clone
      data[:identity_document] = nil
      user = User.new(data)
      expect(user).to_not be_valid

      data = user_data.clone
      data[:identity_document] = 1234
      user = User.new(data)
      expect(user).to_not be_valid
    end

    it "a user won't be valid if his document identity has been registered" do
      data = user_data.clone
      user = User.create(data)
      expect(user).to be_valid

      new_data = data.clone
      new_data[:email] = Faker::Internet.email
      new_data[:username] = Faker::Internet.username
      user = User.create(new_data)
      expect(user).to_not be_valid
    end

    it "checking email user" do
      data = user_data.clone
      data[:email] = nil
      user = User.new(data)
      expect(user).to_not be_valid

      data = user_data.clone
      data[:email] = "hola"
      user = User.new(data)
      expect(user).to_not be_valid

      data = user_data.clone
      data[:email] = "na@"
      user = User.new(data)
      expect(user).to_not be_valid

      data = user_data.clone
      data[:email] = "admin@example.com"
      user = User.new(data)
      expect(user).to be_valid
    end

    it "a user won't be valid if his email has been registered" do
      data = user_data.clone
      user = User.create(data)
      expect(user).to be_valid

      new_data = data.clone
      new_data[:identity_document] = identity_document
      new_data[:username] = Faker::Internet.username
      user = User.create(new_data)
      expect(user).to_not be_valid
    end

    it "a user won't be valid if his email has been registered" do
      data = user_data.clone
      user = User.create(data)
      expect(user).to be_valid

      new_data = data.clone
      new_data[:identity_document] = identity_document
      new_data[:username] = Faker::Internet.username
      user = User.create(new_data)
      expect(user).to_not be_valid
    end

    it "a user won't be valid if his username has been registered" do
      user_name = username
      data = user_data.clone
      data[:username] = user_name
      user = User.create(data)
      expect(user).to be_valid

      new_data = data.clone
      new_data[:identity_document] = identity_document
      new_data[:email] = Faker::Internet.email
      new_data[:username] = user_name.downcase
      user = User.create(new_data)
      expect(user).to_not be_valid

      new_data = data.clone
      new_data[:identity_document] = identity_document
      new_data[:email] = Faker::Internet.email
      new_data[:username] = user_name.upcase
      user = User.create(new_data)
      expect(user).to_not be_valid
    end

=begin

    it "a user doesn't be void" do
      expect(User.new).to_not be_valid
    end

    it "check if the email user is" do
      expect(User.create(email: nil, password: password, person: person)).to_not be_valid
      expect(User.create(email: "", password: password, person: person)).to_not be_valid
      expect(User.create(email: "hola", password: password, person: person)).to_not be_valid
    end

    it "check if the password user is validate" do
      expect(User.create(email: email, password: nil, person: person)).to_not be_valid
      expect(User.create(email: email, password: "", person: person)).to_not be_valid
      expect(User.create(email: email, password: "1234567", person: person)).to_not be_valid
      expect(User.create(email: email, password: "manager", person: person)).to_not be_valid
      expect(User.create(email: email, password: "manager*", person: person)).to_not be_valid
      expect(User.create(email: email, password: "1manager*", person: person)).to_not be_valid
    end

    it "a user can't be to save while don't have a person" do
      person_void = Person.new
      expect(User.create(email: email, password: password, person: nil)).to_not be_valid
      expect(User.create(email: email, password: password, person: person_void)).to_not be_valid
    end

    it "save user unique" do
      expect(User.create(email: email, password: password, person: person)).to be_valid
      expect(User.create(email: email, password: password, person: person)).to_not be_valid
    end


=end

    it "only whether all attributes have been validated" do
      user = User.create(user_data)
      expect(user).to be_valid
    end
  end
end
