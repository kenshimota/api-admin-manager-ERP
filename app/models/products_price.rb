class ProductsPrice < ApplicationRecord
  belongs_to :product
  belongs_to :currency
  has_one :tax, through: :product
  has_many :products_prices_histories, dependent: :destroy

  after_create :create_history_first
  before_update :set_price_was
  after_update :create_history_update

  validates :product_id, presence: true, uniqueness: { scope: :currency_id }
  validates :price, presence: true, numericality: { greater_than: 0 }

  def set_user(current_user)
    @user = current_user
  end

  scope :search, ->(q) { where(product: Product.search(q)) if q and !q.empty? }
  scope :product_id, lambda { |product_id| !product_id ? self : where(product_id: product_id) }
  scope :currency_id, lambda { |currency_id| !currency_id ? self : where(currency_id: currency_id) }
  scope :metadata, ->(check) { joins(:product, :currency, :tax).includes(:product, :currency, :tax) if check }
  scope :available, ->(available) { where(product: Product.where("(products.stock - products.reserved) > 0")) if available }
  scope :filter_order, ->(order_id) { where.not(product: Product.joins(:orders_items).where(orders_items: { order_id: order_id })) if order_id }

  private

  def set_price_was
    @price_was = self.price_was
  end

  def create_history_first
    history = ProductsPricesHistory.new(products_price: self, user: @user, price_before: 0.0, price_after: self.price)
    history.save!
  end

  def create_history_update
    if @price_was == self.price
      return
    end

    history = ProductsPricesHistory.new(
      user: @user,
      products_price: self,
      price_before: @price_was,
      price_after: self.price,
    )
    history.save!
  end
end
