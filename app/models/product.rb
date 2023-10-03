class Product < ApplicationRecord
  belongs_to :tax

  before_create :load_stock_and_reserved

  validates :name, presence: true, length: { minimum: 3 }
  validates :bar_code, allow_blank: true, length: { minimum: 8 }
  validates :code, presence: true, length: { minimum: 3 }, uniqueness: { case_sensitive: false }

  scope :search, lambda { |search|
    if !search
      return self
    end

    where("CONCAT(UPPER(name), ' ', UPPER(bar_code),  ' ', UPPER(code)) LIKE UPPER(?)", "%#{search}%")
  }

  private

  def load_stock_and_reserved
    self.stock = 0
    self.reserved = 0
  end
end
