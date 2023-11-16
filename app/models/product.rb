class Product < ApplicationRecord
  belongs_to :tax
  has_many :inventories, dependent: :destroy
  has_many :products_prices, dependent: :destroy

  before_create :load_stock_and_reserved

  validates :name, presence: true, length: { minimum: 3 }
  validates :bar_code, allow_blank: true, length: { minimum: 8 }
  validates :code, presence: true, length: { minimum: 3 }, uniqueness: { case_sensitive: false }
  validates :stock, numericality: { greater_than_or_equal_to: 0 }
  validates :reserved, numericality: { greater_than_or_equal_to: 0 }
  validate :check_if_reserved_is_greater_than_stock

  scope :metadata, ->(check) { joins(:tax).includes(:tax) if check }

  scope :search, lambda { |search|
    if !search
      return self
    end

    q = "%#{search}%"
    where("UPPER(products.name) LIKE  UPPER(?) ", q)
      .or(where("UPPER(products.code) LIKE  UPPER(?) ", q))
      .or(where("UPPER(products.bar_code) LIKE  UPPER(?) ", q))
  }

  def available
    self.stock - self.reserved
  end

  def get_price(currency_id)
    product_price = self.products_prices.where(currency_id: currency_id).first

    if product_price.nil?
      return 0
    end

    product_price.price
  end

  def get_price_total(currency_id)
    (self.tax.percentage + 1) * self.get_price(currency_id)
  end

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
