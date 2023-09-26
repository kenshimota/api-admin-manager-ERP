class Warehouse < ApplicationRecord
  validates :name, presence: :true, uniqueness: { case_sensitive: false }

  scope :search, lambda { |search|
    if !search
      return self
    end

    where("UPPER(name) LIKE UPPER(?)", "%#{search}%")
      .or(where("UPPER(address) LIKE UPPER(?)", "%#{search}%"))
  }
end
