class City < ApplicationRecord
  validates :name, presence: :true, uniqueness: { case_sensitive: false }

  scope :search, ->(search) { search ? where("UPPER(name) LIKE UPPER(?)", "%#{search}%") : self }
end
