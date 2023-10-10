class Inventory < ApplicationRecord
  belongs_to :product
  belongs_to :warehouse
  has_many :inventories_histories, dependent: :destroy

  before_create :before_create_inventory
  after_create :after_create_inventory

  validate :check_if_reserved_is_greater_than_stock
  validates :stock, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :reserved, presence: true, numericality: { greater_than_or_equal_to: 0 }

  scope :filter_product, ->(product_id) { product_id ? where(product_id: product_id) : self }
  scope :filter_warehouse, ->(warehouse_id) { warehouse_id ? where(warehouse_id: warehouse_id) : self }

  def set_user(current_user)
    @user = current_user
  end

  def reserve_stock(amount)
    ActiveRecord::Base.transaction do
      self.increment :reserved, amount
      self.product.increment :reserved, amount
      self.save!
      self.product.save!
    rescue ActiveRecord::RecordInvalid => e
      raise ActiveRecord::Rollback
    end

    self
  end

  def increment_stock!(amount)
    @stock = self.stock
    self.increment :stock, amount
    self.product.increment :stock, amount
    self.save!
    self.product.save!

    InventoriesHistory.create!(
      user: @user,
      inventory: self,
      before_amount: @stock,
      after_amount: @stock + amount,
      observations: self.observations,
    )
  end

  def increment_stock(amount)
    ActiveRecord::Base.transaction do
      self.increment_stock! amount
    rescue ActiveRecord::RecordInvalid => e
      raise ActiveRecord::Rollback
    end

    self
  end

  private

  def before_create_inventory
    self.reserved = 0
  end

  def after_create_inventory
    self.product.increment! :stock, self.stock
    InventoriesHistory.create!(
      user: @user,
      inventory: self,
      after_amount: self.stock,
      observations: self.observations,
    )
  end

  def check_if_reserved_is_greater_than_stock
    if self.reserved > self.stock
      errors.add(:reserved, I18n.translate(:reserved_is_greater_than_stock))
    end
  end
end
