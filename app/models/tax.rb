class Tax < ApplicationRecord
  validates :name, presence: :true, uniqueness: { case_sensitive: false }
  validates :percentage, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 1 }, uniqueness: true

  scope :search, ->(search) { search ? where("UPPER(name) LIKE UPPER(?)", "%#{search}%") : self }
  # Ex:- scope :active, -> {where(:active => true)}
end
