class User < ApplicationRecord
  include Devise::JWT::RevocationStrategies::JTIMatcher

  # relationship
  has_one :users_role
  has_one :users_customer
  has_one :role, through: :users_role
  has_one :customer, through: :users_customer

  # validation User
  validates :last_name, presence: true, length: { minimum: 3 }
  validates :first_name, presence: true, length: { minimum: 3 }
  validates :username, presence: true, uniqueness: true, length: { minimum: 3 }
  validates :identity_document, presence: true, uniqueness: true, length: { minimum: 6 }
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }, uniqueness: { case_sensitive: false }
  validates :password, presence: false, allow_blank: true, format: { with: /(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[#?!@$%^&*-.]).{8,}/ }

  scope :search, ->(q) { where("CONCAT(UPPER(users.username), ' ', UPPER(users.first_name), ' ', UPPER(users.last_name)) LIKE UPPER(?)", "%#{q}%") if q and !q.empty? }

  scope :metadata, ->(check) { joins(:role, :customer).includes(:role, :customer) if check }

  def metadata_fields 
    [:role, :customer]
  end


  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :jwt_authenticatable, jwt_revocation_strategy: self
end
