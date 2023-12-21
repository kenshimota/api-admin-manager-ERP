class State < ApplicationRecord
  validates :name, presence: :true, uniqueness: { case_sensitive: false }
  scope :search, ->(search) { search ? where("UPPER(states.name) LIKE UPPER(?)", "%#{search}%") : self }
end
