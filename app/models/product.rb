class Product < ApplicationRecord
  belongs_to :tax

  before_create :load_stock_and_reserved

  validates :name, presence: true, length: { minimum: 3 }
  validates :bar_code, allow_blank: true, length: { minimum: 8 }
  validates :code, presence: true, length: { minimum: 3 }, uniqueness: { case_sensitive: false }
  validates :stock, numericality: { greater_than_or_equal_to: 0 }
  validates :reserved, numericality: { greater_than_or_equal_to: 0 }
  validate :check_if_reserved_is_greater_than_stock

  scope :search, lambda { |search|
    if !search
      return self
    end

    where("CONCAT(UPPER(name), ' ', UPPER(bar_code),  ' ', UPPER(code)) LIKE UPPER(?)", "%#{search}%")
  }

  private

  def check_if_reserved_is_greater_than_stock
    if self.reserved > self.stock
      errors.add(:reserved, I18n.translate(:reserved_is_greater_than_stock))
    end
  end

  def load_stock_and_reserved
    self.stock = 0
    self.reserved = 0
  end
end
