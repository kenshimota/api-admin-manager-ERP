class Order < ApplicationRecord
  belongs_to :user
  belongs_to :customer
  belongs_to :currency
  belongs_to :orders_status
  has_many :orders_items

  validates :number, uniqueness: { case_sensitive: false }
  validates :total, numericality: { greater_than_or_equal_to: 0 }
  validates :subtotal, numericality: { greater_than_or_equal_to: 0 }
  validates :tax_amount, numericality: { greater_than_or_equal_to: 0 }
  validates :products_count, numericality: { greater_than_or_equal_to: 0 }
  validates :quantity_total, numericality: { greater_than_or_equal_to: 0 }

  before_validation :before_create_an_order, on: :create
  before_validation :before_update_an_order, on: :update
  before_destroy :before_destroy_an_order

  scope :user_id, ->(value) { where(user_id: value) if value }
  scope :currency_id, ->(value) { where(currency_id: value) if value }
  scope :customer_id, ->(value) { where(customer_id: value) if value }

  scope :metadata, ->(check) {
          joins(:user, :customer, :currency, :orders_status)
            .includes(:user, :customer, :currency, :orders_status) if check
        }

  scope :orders_status_id, ->(value) { where(orders_status_id: value) if value }
  scope :search, ->(q) { where(customer: Customer.search(q)).or(where(user: User.search(q))) if q and !q.empty? }

  def set_user(current_user)
    @user = current_user
  end

  private

  def before_destroy_an_order
    before_update_an_order
    throw(:abort) if self.errors.present?

    self.orders_items.each do |item|
      item.destroy
    end
  end

  def before_update_an_order
    orders_status_id = self.orders_status_id_was
    order_status = OrdersStatus.where(id: orders_status_id).first

    if order_status.name != ORDER_STATUSES_NAME[:pending]
      errors.add(:orders_status_id, I18n.t(:dont_update_order))
    end

    status = OrdersStatus.where(id: self.orders_status_id).first

    if self.errors.present? == false
      case status.name
      when ORDER_STATUSES_NAME[:invoiced]
        self.orders_items.each do |item|
          item.invoice @user
        end
      end
    end
  end

  def before_create_an_order
    number = 1
    last_order = Order.last
    pending_status = OrdersStatus.find_by(name: ORDER_STATUSES_NAME[:pending])

    if last_order
      number = last_order.number + 1
    end

    self.number = number
    self.orders_status_id = pending_status.id
    self.tax_amount = 0
    self.subtotal = 0
    self.total = 0
    self.products_count = 0
    self.quantity_total = 0
  end
end
