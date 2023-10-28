class Customer < ApplicationRecord
  belongs_to :state
  belongs_to :city
  has_many :customers_phones
  has_many :phones, through: :customers_phones

  validates :name, presence: true, length: { minimum: 3 }
  validates :last_name, presence: true, length: { minimum: 3 }
  validates :identity_document, presence: true, uniqueness: true, length: { minimum: 6 }

  scope :search, lambda { |search|
    if !search
      return self
    end

    where("CONCAT(UPPER(name), ' ', UPPER(last_name)) LIKE UPPER(?)", "%#{search}%")
      .or(where("CAST(identity_document AS TEXT) LIKE ?", "%#{search}%"))
  }
end
