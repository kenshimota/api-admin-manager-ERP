class User < ApplicationRecord
  include Devise::JWT::RevocationStrategies::JTIMatcher

  # validation User
  validates :last_name, presence: true, length: { minimum: 3 }
  validates :first_name, presence: true, length: { minimum: 3 }
  validates :username, presence: true, uniqueness: true, length: { minimum: 3 }
  validates :identity_document, presence: true, uniqueness: true, length: { minimum: 6 }
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }, uniqueness: { case_sensitive: false }
  validates :password, presence: true, format: { with: /(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[#?!@$%^&*-.]).{8,}/ }

  scope :search, ->(q) { where("CONCAT(UPPER(username), ' ', UPPER(first_name), ' ', UPPER(last_name)) LIKE UPPER(?)", "%#{q}%") if q and !q.empty? }

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :jwt_authenticatable, jwt_revocation_strategy: self
end
