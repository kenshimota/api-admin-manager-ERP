class Currency < ApplicationRecord
  validates :symbol, presence: true
  validates :name, presence: true, uniqueness: { case_sensitive: false }
  validates :code, presence: true, uniqueness: { case_sensitive: false }
  validates :exchange_rate, presence: true, numericality: { greater_than: 0 }

  scope :search, lambda { |search|
    if !search
      return self
    end

    where("CONCAT(UPPER(currencies.name), ' ', UPPER(currencies.code), ' ', UPPER(currencies.symbol)) LIKE UPPER(?)", "%#{search}%")
  }
end
