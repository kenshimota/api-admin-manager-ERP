class Product < ApplicationRecord
  belongs_to :tax

  before_create :load_stock_and_reserved

  validates :name, presence: true, length: { minimum: 3 }
  validates :bar_code, allow_blank: true, length: { minimum: 12 }
  validates :code, presence: true, length: { minimum: 3 }, uniqueness: { case_sensitive: false }

  private

  def load_stock_and_reserved
    self.stock = 0
    self.reserved = 0
  end
end
