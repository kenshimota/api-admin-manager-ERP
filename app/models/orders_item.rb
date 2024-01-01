class OrdersItem < ApplicationRecord
  belongs_to :order
  belongs_to :product
  belongs_to :currency
  has_many :items_inventories
  has_one :customer, through: :order

  after_save :update_order
  after_create :reserved_stock
  before_destroy :before_destroy_item
  before_validation :before_create_item, on: :create

  scope :order_id, lambda { |order_id| where(order_id: order_id) if order_id }
  scope :product_id, lambda { |product_id| where(product_id: product_id) if product_id }
  scope :currency_id, lambda { |currency_id| where(currency_id: currency_id) if currency_id }
  scope :customer_id, lambda { |customer_id| where(order: Order.where(customer_id: customer_id)) if customer_id }
  scope :metadata, ->(check) { joins(:order, :product, :currency, :customer).includes(:order, :product, :currency, :customer) if check }

  def invoice(current_user)
    self.items_inventories.each do |item|
      item.inventory.set_user current_user
      item.inventory.reserve_stock! -item.quantity
      item.inventory.increment_stock! -item.quantity
    end
  end

  private

  def before_destroy_item
    status = self.order.orders_status

    if status.name != ORDER_STATUSES_NAME[:pending]
      errors.add(:order_id, I18n.t(:dont_update_order))
      throw(:abort)
    end

    self.items_inventories.each do |history|
      history.inventory.reserve_stock history.quantity * (-1)
      history.destroy
    end

    self.increment_fields_order(
      products_count: -1,
      quantity_total: -self.quantity,
      subtotal: -self.subtotal,
      tax_amount: -self.tax_amount,
      total: -self.total,
    )
  end

  def update_order
    order = self.order
    self.increment_fields_order(
      products_count: 1,
      quantity_total: self.quantity,
      subtotal: self.subtotal,
      tax_amount: self.tax_amount,
      total: self.total,
    )
  end

  def increment_fields_order(attributes)
    set = []

    attributes.each do |key, value|
      symbol = value >= 0 ? "+" : "-"
      set << "\"#{key}\" = COALESCE(\"#{key}\", 0) #{symbol} #{value.abs}"
    end

    if set.length == 0
      return
    end

    Order
      .where(id: self.order_id)
      .update_all(set.join(", "))
  end

  def reserved_stock
    quantity = self.quantity
    product = self.product

    inventories = Inventory.where(product_id: product.id).where("stock > 0")

    inventories_reversed = inventories.reverse

    while quantity > 0 and inventories_reversed.length > 0
      inventory = inventories_reversed.pop
      inventory.lock!
      to_reserve = quantity > inventory.available ? inventory.available : quantity
      inventory.reserve_stock to_reserve
      quantity -= to_reserve
      ItemsInventory.create!(orders_item_id: self.id, inventory_id: inventory.id, quantity: to_reserve)
    end
  end

  def before_create_item
    if self.quantity.nil? or self.quantity <= 0
      errors.add(:quantity, I18n.t("errors.messages.greater_than", count: 0))
      return
    end

    if !self.product_id
      errors.add(:product_id, I18n.t("errors.messages.empty"))
      return
    end

    if !self.order_id
      errors.add(:order_id, I18n.t("errors.messages.empty"))
      return
    end

    current = OrdersItem
      .where(product_id: self.product_id, order_id: self.order_id)
      .first

    if current
      errors.add(:product_id, "errors.messages.taken")
      return
    end

    currency = self.order.currency
    product = self.product
    product.lock!

    if product.get_price_total(currency.id).to_f <= 0
      errors.add(:product_id, I18n.t("product_must_have_price"))
      return
    end

    quantity = product.available >= self.quantity ? self.quantity : product.available

    self.quantity = quantity
    self.currency_id = currency.id
    self.price_without_tax = product.get_price currency.id
    self.price = product.get_price_total currency.id
    self.subtotal = self.price_without_tax * self.quantity
    self.tax_amount = self.price * quantity - self.subtotal
    self.total = self.subtotal + self.tax_amount
  end
end
